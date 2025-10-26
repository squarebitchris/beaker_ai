class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show ]

  def index
    @users = User.order(created_at: :desc)
                 .includes(:trials)
                 .limit(50)
  end

  def show
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
