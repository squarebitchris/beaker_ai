require 'simplecov'

SimpleCov.start 'rails' do
  # Set minimum coverage threshold
  minimum_coverage 90

  # Exclude directories from coverage
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/db/'
  add_filter '/bin/'
  add_filter '/lib/tasks/'
  add_filter '/app/assets/'
  add_filter '/app/javascript/'
  add_filter '/app/views/'
  add_filter '/app/helpers/'
  add_filter '/app/mailers/'

  # Exclude files
  add_filter 'application.rb'
  add_filter 'application_record.rb'
  add_filter 'application_job.rb'
  add_filter 'application_mailer.rb'
  add_filter 'application_controller.rb'
  add_filter 'application_helper.rb'

  # Track specific groups
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Services', 'app/services'
  add_group 'Jobs', 'app/jobs'
  add_group 'Concerns', 'app/concerns'

  # Generate both HTML and console reports
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::SimpleFormatter
  ])

  # Track branches for better coverage analysis
  track_files 'app/**/*.rb'
end
