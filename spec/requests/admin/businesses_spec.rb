require 'rails_helper'

RSpec.describe "Admin::Businesses", type: :request do
  let(:admin_user) { create(:user, admin: true) }
  let(:regular_user) { create(:user, admin: false) }

  before { sign_in admin_user }

  describe "GET /admin/businesses" do
    let!(:business1) { create(:business, name: "Test Business 1", plan: 'starter') }
    let!(:business2) { create(:business, name: "Test Business 2", plan: 'pro') }

    it "returns successful response" do
      get admin_businesses_path
      expect(response).to be_successful
    end

    it "displays businesses" do
      get admin_businesses_path
      expect(response.body).to include(business1.name)
      expect(response.body).to include(business2.name)
    end

    it "orders businesses by created_at descending" do
      get admin_businesses_path
      # Verify both businesses are in the response
      expect(response.body).to include(business1.name)
      expect(response.body).to include(business2.name)
    end

    context "when user is not admin" do
      before { sign_in regular_user }

      it "redirects to root path with alert" do
        get admin_businesses_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end
  end

  describe "GET /admin/businesses/:id" do
    let(:business) { create(:business, name: "Test Business") }

    it "returns successful response" do
      get admin_business_path(business)
      expect(response).to be_successful
    end

    it "displays business details" do
      get admin_business_path(business)
      expect(response.body).to include(business.name)
      expect(response.body).to include(business.plan.upcase)
      expect(response.body).to include(business.status)
    end

    it "displays stripe customer ID" do
      get admin_business_path(business)
      expect(response.body).to include(business.stripe_customer_id)
    end

    context "when user is not admin" do
      before { sign_in regular_user }

      it "redirects to root path with alert" do
        get admin_business_path(business)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end
  end
end
