class Admin::WebhookEventsController < Admin::BaseController
  before_action :set_webhook_event, only: [ :show, :reprocess ]

  def index
    @webhook_events = WebhookEvent.order(created_at: :desc)

    # Apply filters
    @webhook_events = @webhook_events.where(provider: params[:provider]) if params[:provider].present?
    @webhook_events = @webhook_events.where(status: params[:status]) if params[:status].present?
    @webhook_events = @webhook_events.where("event_id ILIKE ?", "%#{params[:search]}%") if params[:search].present?

    @webhook_events = @webhook_events.limit(100)
  end

  def show
  end

  def reprocess
    unless @webhook_event.failed? || @webhook_event.pending?
      redirect_to admin_webhook_event_path(@webhook_event),
                  alert: "Can only reprocess failed or pending events"
      return
    end

    @webhook_event.update!(status: "pending", error_message: nil, retries: 0)
    WebhookProcessorJob.perform_later(@webhook_event.id)

    Rails.logger.info("[Admin] Webhook event #{@webhook_event.id} reprocessed by #{current_user.email}")

    redirect_to admin_webhook_event_path(@webhook_event),
                notice: "Event queued for reprocessing"
  end

  private

  def set_webhook_event
    @webhook_event = WebhookEvent.find(params[:id])
  end
end
