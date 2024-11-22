require 'rails_helper'

RSpec.describe ExpensesController, type: :controller do
  let(:user) { create(:user) }
  let(:group) { create(:group, user: user) }
  let(:expense) { create(:expense, group: group, user: user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns expenses for the group' do
      get :index, params: { group_id: group.id }
      expect(assigns(:expenses)).to include(expense)
    end

    context 'when searching expenses' do
      it 'filters by name' do
        get :index, params: { group_id: group.id, search: expense.name }
        expect(assigns(:expenses)).to include(expense)
      end

      it 'filters by date' do
        get :index, params: { group_id: group.id, date: expense.date }
        expect(assigns(:expenses)).to include(expense)
      end

      it 'filters by amount' do
        get :index, params: { group_id: group.id, amount: expense.amount }
        expect(assigns(:expenses)).to include(expense)
      end
    end
  end

  describe 'GET #new' do
    it 'assigns a new expense' do
      get :new, params: { group_id: group.id }
      expect(assigns(:expense)).to be_a_new(Expense)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { group_id: group.id, expense: { name: 'Lunch', amount: 50, date: Date.today }, split_type: 'equal' } }

      it 'creates a new expense' do
        expect do
          post :create, params: valid_params
        end.to change(Expense, :count).by(1)
      end

      it 'redirects to the group expenses page' do
        post :create, params: valid_params
        expect(response).to redirect_to(group_expenses_path(group))
        expect(flash[:notice]).to eq('Expense created')
      end

      it 'creates corresponding ExpenseSplits' do
        expect do
          post :create, params: valid_params
        end.to change(ExpenseSplit, :count).by(group.users.count)
      end

      it 'creates ExpenseSplits with the correct amount and user' do
        group.users << create(:user)
        split_amount = 50 / group.users.count

        post :create, params: valid_params

        ExpenseSplit.where(expense: assigns(:expense)).each do |split|
          expect(split.amount).to eq(split_amount)
          expect(group.users).to include(split.user)
        end
      end
    end

    context 'with unequal split' do
      let(:valid_params_unequal) { { group_id: group.id, expense: { name: 'Dinner', amount: 100, date: Date.today }, user_ids: [user.id], amounts: { user.id.to_s => 100 } } }

      it 'creates ExpenseSplits with unequal amounts' do
        post :create, params: valid_params_unequal

        split = ExpenseSplit.find_by(expense: assigns(:expense), user: user)
        expect(split.amount).to eq(100)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { group_id: group.id, expense: { name: '', amount: -10, date: Date.today }, split_type: 'equal' } }

      it 'does not create a new expense' do
        expect do
          post :create, params: invalid_params
        end.not_to change(Expense, :count)
      end

      it 'renders the new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to include("Name can't be blank", 'Amount must be greater than 0')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the expense' do
      expect do
        delete :destroy, params: { group_id: group.id, id: expense.id }
      end.to change(Expense, :count).by(0)
    end

    it 'redirects to the group expenses page' do
      delete :destroy, params: { group_id: group.id, id: expense.id }
      expect(response).to redirect_to(group_expenses_path(group))
      expect(flash[:notice]).to eq('Expense  deleted.')
    end

    context 'when the expense is not found' do
      it 'redirects with an error' do
        delete :destroy, params: { group_id: group.id, id: 'nonexistent' }
        expect(response).to redirect_to(group_expenses_path(group))
        expect(flash[:alert]).to eq('Expense not found.')
      end
    end
  end
end
