require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  include Devise::Test::ControllerHelpers
  let(:user) { create(:user, name: 'test1', email: 'test1@gmail.com', password: '123456') }
  let(:other_user) { create(:user) }
  let(:group) { create(:group, user: user, name: 'Test1') }
  let(:other_group) { create(:group, user: other_user, name: 'Test2') }

  before do
    sign_in user
  end

  describe 'GET #index' do
    context 'when logged in' do
      it 'assigns the user’s groups and renders index' do
        get :index
        expect(assigns(:groups)).to eq(user.groups)
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end
    end

    context 'when not logged in' do
      before { sign_out user }

      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #new' do
    context 'when logged in' do
      it 'assigns a new group and available users, and renders new' do
        get :new
        expect(assigns(:group)).to be_a_new(Group)
        expect(assigns(:users)).to match_array(User.where.not(id: user.id))
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when not logged in' do
      before { sign_out user }

      it 'redirects to the login page' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { group: { name: 'Test Group', user_ids: [other_user.id] } } }
    let(:invalid_params) { { group: { name: '' } } }

    context 'with valid params' do
      it 'creates a new group and memberships, then redirects to index' do
        expect { post :create, params: valid_params }.to change(Group, :count).by(1).and change(Membership, :count).by(2)
        expect(response).to redirect_to(groups_path)
      end
    end

    context 'with invalid params' do
      it 'does not create a group, re-renders the new template' do
        expect { post :create, params: invalid_params }.not_to change(Group, :count)
        expect(response).to render_template(:new)
      end
    end

    context 'when not logged in' do
      before { sign_out user }

      it 'does not create a group and redirects to login' do
        expect { post :create, params: valid_params }.not_to change(Group, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when logged in and group owner' do
      it 'deletes the group and redirects to index' do
        group
        expect { delete :destroy, params: { id: group.id } }.to change(Group, :count).by(-1)
        expect(response).to redirect_to(groups_path)
      end
    end
    context 'when not logged in' do
      before { sign_out user }

      it 'does not delete' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET #part_of' do
    context 'when logged in' do
      it 'assigns the user’s group memberships and renders the view' do
        get :part_of
        expect(assigns(:groups)).to eq(user.group_memberships)
        expect(response).to render_template(:part_of)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when not logged in' do
      before { sign_out user }

      it 'redirects to the login page' do
        get :part_of
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end