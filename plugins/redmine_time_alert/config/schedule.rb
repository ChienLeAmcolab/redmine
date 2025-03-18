# Log path for cron (optional)
set :output, "log/cron.log"

# Environmental setting (if necessary)
set :environment, ENV['RAILS_ENV'] || 'development'

# Schedule Rake Task "Redmine: Time_alert" at 8:00 am every day
every 1.day, at: '8:00 am' do
  rake "redmine:time_alert"
end
