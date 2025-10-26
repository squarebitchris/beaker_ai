class BusinessesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business

  def dashboard
    @recent_calls = @business.calls
                             .order(created_at: :desc)
                             .limit(20)
  end

  private

  def set_business
    @business = current_user.businesses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Business not found"
    redirect_to root_path
  end
end
