class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_FROM', 'Beaker AI <noreply@beaker.ai>')
  layout "mailer"
end
