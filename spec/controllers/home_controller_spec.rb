require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe 'GET #index' do
    context "it is the front page" do
      it "works successfully" do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
