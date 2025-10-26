class Admin::DashboardController < Admin::BaseController
  def index
    @webhook_events_today = WebhookEvent.where("created_at >= ?", 1.day.ago).count
    @businesses_total = Business.count
    @users_total = User.count
  end
end
