# plugins/restrict_timelog/app/models/restrict_timelog/time_entry_patch.rb
module RestrictTimelog
  module TimeEntryPatch
    def self.included(base)
      base.class_eval do
        # Gộp chung 2 validation chỉ chạy khi tracker không nằm trong allowed
        with_options unless: :allowed_tracker? do
          validate :must_not_log_epic_or_story
          validate :date_within_issue_range
        end

        private

        # Tracker nằm trong danh sách cho phép hay không?
        def allowed_tracker?
          ids = Setting.plugin_restrict_timelog['allowed_tracker_ids'] || []
          ids.map(&:to_i).include?(issue.tracker_id)
        end

        # Không cho log nếu tracker không phải Epic/Story và không được phép
        def must_not_log_epic_or_story
          return if issue_id.blank?
          if issue.tracker.name.in?(%w[Epic Story])
            # nếu là Epic/Story thì pass
            return
          end
          errors.add(:issue, :invalid_tracker)
        end

        # Kiểm tra ngày spent_on nằm trong khoảng [start_date, due_date] của issue
        def date_within_issue_range
          return if issue_id.blank? || spent_on.nil?
          # nếu issue không có start_date/due_date thì bỏ qua tương ứng
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
