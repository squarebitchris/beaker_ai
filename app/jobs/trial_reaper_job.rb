class TrialReaperJob < ApplicationJob
  queue_as :low  # Low priority, run during off-hours

  def perform
    cutoff_date = 7.days.ago

    # Find expired trials older than 7 days (excluding converted ones)
    expired_trials = Trial.where("expires_at < ?", cutoff_date)
                          .where.not(status: "converted")

    count = expired_trials.count

    return if count.zero?

    Rails.logger.info("[TrialReaper] Deleting #{count} expired trials older than #{cutoff_date}")

    # Delete trials (use destroy_all to trigger dependent: :destroy callbacks for calls)
    expired_trials.destroy_all

    # Alert if massive cleanup (potential abuse or system issue)
    if count > 100
      Sentry.capture_message(
        "Large trial cleanup: #{count} trials deleted",
        level: :warning,
        extra: {
          cutoff_date: cutoff_date.iso8601,
          deleted_count: count
        }
      )
    end

    Rails.logger.info("[TrialReaper] Cleanup complete. Deleted #{count} trials.")
  end
end
