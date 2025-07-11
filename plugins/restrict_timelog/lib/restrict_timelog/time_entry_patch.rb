# plugins/restrict_timelog/lib/restrict_timelog/time_entry_patch.rb
module RestrictTimelog
  module TimeEntryPatch
    def self.included(base)
      base.class_eval do
        # 1) Cấm log cho tracker Epic/Story
        validate :must_not_log_epic_or_story
        # 2) Validate ngày trong khoảng start_date..due_date của issue
        validate :date_within_issue_range

        private

        def must_not_log_epic_or_story
          return unless issue_id.present? && issue
          if issue.tracker.name.in?(%w[Epic Story])
            errors.add(:issue, :invalid_tracker)
          end
        end

        def date_within_issue_range
          # Chỉ chạy nếu có issue và không bị cấm tracker
          return unless issue_id.present? && issue && !issue.tracker.name.in?(%w[Epic Story]) && spent_on

          if issue.start_date && spent_on < issue.start_date
            errors.add(:spent_on, :before_issue_start,
                       start: issue.start_date.to_s)
          elsif issue.due_date && spent_on > issue.due_date
            errors.add(:spent_on, :after_issue_due,
                       due:   issue.due_date.to_s)
          end
        end
      end
    end
  end
end

TimeEntry.send(:include, RestrictTimelog::TimeEntryPatch)
