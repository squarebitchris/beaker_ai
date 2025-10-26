class Admin::WebhookEventsController < Admin::BaseController
  before_action :set_webhook_event, only: [ :show ]

  def index
    @webhook_events = WebhookEvent.order(created_at: :desc)
                                   .limit(100)
  end

  def show
  end

  private

  def set_webhook_event
    @webhook_event = WebhookEvent.find(params[:id])
  end
end
