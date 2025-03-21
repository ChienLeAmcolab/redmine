require_dependency 'redmine_time_alert/lib/patches/user_patch'
namespace :redmine_time_alert do
  desc <<~DESC
    Send an email warning to users if the total logged hours yesterday is less than 8 hours
    and the alert settings have been enabled.
    
    This task should be scheduled to run at 8:00 am every day to remind users.
    
    Options:
      * dry_run - Print the list of users to the console instead of sending emails.
    
    For example:
      rake redmine_time_alert:time_alert RAILS_ENV=production
      rake redmine_time_alert:time_alert dry_run=1 RAILS_ENV=production
  DESC
  task time_alert: :environment do
    dry_run = ENV['dry_run']

    User.where(status: User::STATUS_ACTIVE).find_each do |user|
      if user.need_time_alert?
        if dry_run
          $stdout.puts "#{user.name} <#{user.mail}>"
        else
          TimeAlertMailer.time_alert_notification(user).deliver_now
        end
      end
    end
  end
end
