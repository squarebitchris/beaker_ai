class Admin::BusinessesController < Admin::BaseController
  before_action :set_business, only: [ :show ]

  def index
    @businesses = Business.order(created_at: :desc)
                          .includes(:owners)
                          .limit(50)
  end

  def show
  end

  private

  def set_business
    @business = Business.find(params[:id])
  end
end
