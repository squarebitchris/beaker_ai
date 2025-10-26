require "rails_helper"

RSpec.describe StripePlan, type: :model do
  describe "validations" do
    it { should validate_presence_of(:plan_name) }
    it { should validate_presence_of(:stripe_price_id) }
    it { should validate_numericality_of(:base_price_cents).is_greater_than(0) }
    it { should validate_numericality_of(:calls_included).is_greater_than(0) }
    it { should validate_numericality_of(:overage_cents_per_call).is_greater_than_or_equal_to(0) }

    it "validates uniqueness of plan_name" do
      create(:stripe_plan, plan_name: "starter")
      duplicate = build(:stripe_plan, plan_name: "starter")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:plan_name]).to include("has already been taken")
    end

    it "validates uniqueness of stripe_price_id" do
      create(:stripe_plan, stripe_price_id: "price_123")
      duplicate = build(:stripe_plan, stripe_price_id: "price_123")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:stripe_price_id]).to include("has already been taken")
    end
  end

  describe "scopes" do
    let!(:active_plan) { create(:stripe_plan, plan_name: "starter", active: true) }
    let!(:inactive_plan) { create(:stripe_plan, plan_name: "pro", active: false) }

    it "returns only active plans" do
      expect(StripePlan.active).to include(active_plan)
      expect(StripePlan.active).not_to include(inactive_plan)
    end
  end

  describe ".for_plan" do
    let!(:starter_plan) { create(:stripe_plan, plan_name: "starter", active: true) }
    let!(:pro_plan) { create(:stripe_plan, plan_name: "pro", active: true) }

    it "finds plan by name" do
      expect(StripePlan.for_plan("starter")).to eq(starter_plan)
      expect(StripePlan.for_plan("pro")).to eq(pro_plan)
    end

    it "returns nil for non-existent plan" do
      expect(StripePlan.for_plan("nonexistent")).to be_nil
    end

    it "returns nil for inactive plan" do
      starter_plan.update!(active: false)
      expect(StripePlan.for_plan("starter")).to be_nil
    end

    it "handles symbol input" do
      expect(StripePlan.for_plan(:starter)).to eq(starter_plan)
    end
  end

  describe "#base_price_dollars" do
    it "converts cents to dollars" do
      plan = create(:stripe_plan, base_price_cents: 199_00)
      expect(plan.base_price_dollars).to eq(199.0)
    end

    it "handles odd amounts" do
      plan = create(:stripe_plan, base_price_cents: 12345)
      expect(plan.base_price_dollars).to eq(123.45)
    end
  end
end
