require 'rails_helper'

RSpec.describe "Admin::BaseController", type: :request do
  describe "authentication and authorization" do
    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get admin_root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated but not admin" do
      let(:user) { create(:user, admin: false) }

      before { sign_in user }

      it "redirects to root path with alert" do
        get admin_root_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end

      it "does not allow access to any admin route" do
        get admin_webhook_events_path
        expect(response).to redirect_to(root_path)

        get admin_businesses_path
        expect(response).to redirect_to(root_path)

        get admin_users_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is admin" do
      let(:admin_user) { create(:user, admin: true) }

      before { sign_in admin_user }

      it "allows access to admin routes" do
        get admin_root_path
        expect(response).to be_successful
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
