module RestrictTimelog
  module TimeEntryPatch
    def self.included(base)
      base.class_eval do
        validate :must_not_log_epic_or_story
        validate :date_within_issue_range

        private

        # Lấy danh sách tracker được phép ngoại lệ (Array of Integer)
        def allowed_tracker_ids
          ids = Setting.plugin_restrict_timelog['allowed_tracker_ids'] || []
          ids.map(&:to_i)
        end

        def must_not_log_epic_or_story
          return unless issue_id.present? && issue

          # Nếu tracker đang được ngoại lệ, bỏ qua validation
          return if allowed_tracker_ids.include?(issue.tracker_id)

          if issue.tracker.name.in?(%w[Epic Story])
            errors.add(:issue, :invalid_tracker)
          end
        end

        def date_within_issue_range
          return unless issue_id.present? && issue && spent_on

          # Bỏ qua nếu tracker ngoại lệ
          return if allowed_tracker_ids.include?(issue.tracker_id)
          # Bỏ qua nếu tracker Epic/Story (như cũ)
          return if issue.tracker.name.in?(%w[Epic Story])

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
