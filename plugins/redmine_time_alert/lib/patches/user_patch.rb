module RedmineTimeAlert
  module UserPatch
    def self.included(base)
      base.class_eval do
       # Calculate the last working day to check the number of hours log:
       # - If today is Sunday or Monday, returns to the Friday of last week.
        # + If today is Monday, yesterday is Sunday (rest), so taken on Friday by deducting 3 days.
        # + If today is Sunday, yesterday is Saturday (break), so taken on Friday by deducting 2 days.
        # - Other days, yesterday is considered a working day.
        def last_working_day
          today = Date.today
          if today.sunday? || today.monday?
            today.monday? ? today - 3 : today - 2
          else
            Date.yesterday
          end
        end

        # Calculate the total number of logos of the user on the last working day
        def time_logged_last_working_day
          TimeEntry.where(user_id: id, spent_on: last_working_day).sum(:hours).to_f
        end

        # Check if it is necessary to send the warning:
        # If the total number of logos of the last working day is less than 8 and the warning settings are turned on in the user's preference.
        def need_time_alert?
          time_logged_last_working_day < 8 && self.pref.time_alert_enabled?
        end
      end
    end
  end
end

unless User.included_modules.include?(RedmineTimeAlert::UserPatch)
  User.send(:include, RedmineTimeAlert::UserPatch)
end
