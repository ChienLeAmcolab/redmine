module RestrictTimelog
  module TimeEntryPatch
    def self.included(base)
      base.class_eval do
        # khai báo validation kèm điều kiện bỏ qua nếu allowed_tracker?
        validate :must_not_log_epic_or_story, unless: :allowed_tracker?
        validate :date_within_issue_range,     unless: :allowed_tracker?

        private

        # method kiểm tra tracker có được phép ngoại lệ không
        def allowed_tracker?
          ids = Setting.plugin_restrict_timelog['allowed_tracker_ids'] || []
          ids.map(&:to_i).include?(issue.tracker_id)
        end

        def must_not_log_epic_or_story
          # ở đây chỉ chạy nếu tracker không nằm trong allowed
          return if issue_id.blank? || issue.tracker.name.in?(%w[Epic Story])
          errors.add(:issue, :invalid_tracker)
        end

        def date_within_issue_range
          return if issue_id.blank? || issue.tracker.name.in?(%w[Epic Story])
          return unless spent_on
          if issue.start_date && spent_on < issue.start_date
            errors.add(:spent_on, :before_issue_start, start: issue.start_date.to_s)
          elsif issue.due_date && spent_on > issue.due_date
            errors.add(:spent_on, :after_issue_due,  due:   issue.due_date.to_s)
          end
        end
      end
    end
  end
end
