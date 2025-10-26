# app/lib/quiet_hours.rb
module QuietHours
  START_HOUR = 8
  END_HOUR = 21

  # ⚠️ PHASE 1 TEMPORARY ONLY: Uses fixed timezone
  # **TCPA VIOLATION RISK**: Using business timezone instead of recipient timezone
  # is a $500-$1,500 per call TCPA violation
  # TODO Phase 4.5 (R2-E07-T003): Replace with PhoneTimezone.lookup(e164_phone)
  def self.allow?(e164_phone)
    now = Time.current.in_time_zone("America/Chicago")
    now.hour >= START_HOUR && now.hour < END_HOUR
  end
end
