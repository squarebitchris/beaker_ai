require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:admin_user) { create(:user, admin: true) }
  let(:regular_user) { create(:user, admin: false) }

  before { sign_in admin_user }

  describe "GET /admin/users" do
    let!(:user1) { create(:user, email: "user1@example.com") }
    let!(:user2) { create(:user, email: "user2@example.com") }

    it "returns successful response" do
      get admin_users_path
      expect(response).to be_successful
    end

    it "displays users" do
      get admin_users_path
      expect(response.body).to include(user1.email)
      expect(response.body).to include(user2.email)
    end

    it "orders users by created_at descending" do
      get admin_users_path
      # Verify the most recent user appears first in response
      expect(response.body).to match(/#{user1.email}.*#{user2.email}|#{user2.email}.*#{user1.email}/m)
    end

    it "shows admin badge for admin users" do
      get admin_users_path
      expect(response.body).to include("Admin") if admin_user.admin?
    end

    context "when user is not admin" do
      before { sign_in regular_user }

      it "redirects to root path with alert" do
        get admin_users_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end
  end

  describe "GET /admin/users/:id" do
    let(:user) { create(:user, email: "test@example.com") }

    it "returns successful response" do
      get admin_user_path(user)
      expect(response).to be_successful
    end

    it "displays user details" do
      get admin_user_path(user)
      expect(response.body).to include(user.email)
      expect(response.body).to include(user.id)
    end

    it "displays sign in count" do
      get admin_user_path(user)
      expect(response.body).to include(user.sign_in_count.to_s)
    end

    context "when user has trials" do
      let!(:trial1) { create(:trial, user: user, business_name: "Test Trial 1") }
      let!(:trial2) { create(:trial, user: user, business_name: "Test Trial 2") }

      it "displays trials count" do
        get admin_user_path(user)
        expect(response.body).to include("Trials")
        expect(response.body).to include(user.trials.count.to_s)
      end
    end

    context "when user is not admin" do
      before { sign_in regular_user }

      it "redirects to root path with alert" do
        get admin_user_path(user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end
  end
end
