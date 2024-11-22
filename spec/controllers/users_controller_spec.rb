require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:expense) { create(:expense, user: user) }
  let(:expense_split) { create(:expense_split, user: other_user, expense: expense, amount: 100) }

  before { sign_in user }

  describe 'GET #profile' do
    context 'when the user is logged in' do
      before do
        expense
        expense_split
      end

      it 'calculates amounts owed to the user ' do
        amounts_owed_to_you = controller.send(:calculate_amounts_owed, user)
        expect(amounts_owed_to_you).to eq({ other_user.id => 100 })
      end

      it 'calculates debts for the user' do
        debts = controller.send(:calculate_user_debts, user)
        expect(debts).to eq({})
      end

      it 'calculates net balances directly' do
        amounts_owed_to_you = { other_user.id => 100 }
        debts = { other_user.id => 50 }
        net_balances = controller.send(:calculate_net_balances, amounts_owed_to_you, debts)
        expect(net_balances).to eq({ other_user.id => 50 })
      end

      it 'rejects zero net balances directly' do
        amounts_owed_to_you = { other_user.id => 100 }
        debts = { other_user.id => 100 }
        net_balances = controller.send(:calculate_net_balances, amounts_owed_to_you, debts)
        expect(net_balances).to eq({})
      end

      it 'renders the profile template' do
        get :profile
        expect(response).to render_template(:profile)
      end

      it 'returns a success status' do
        get :profile
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the user is not logged in' do
      before { sign_out user }

      it 'redirects to the login page' do
        get :profile
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
