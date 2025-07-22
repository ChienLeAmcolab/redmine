# plugins/restrict_timelog/app/models/restrict_timelog/time_entry_patch.rb
module RestrictTimelog
  module TimeEntryPatch
    def self.included(base)
      base.class_eval do
        # Các rule riêng của plugin – chỉ chạy khi tracker KHÔNG được phép
        validate :must_not_log_epic_or_story_unless_allowed
        validate :date_within_issue_range_unless_allowed

        # Nếu tracker được phép, xóa sạch lỗi từ mọi validate khác
        after_validation :wipe_errors_if_allowed_tracker

        private

        # Tracker nằm trong danh sách cho phép?
        def allowed_tracker?
          raw = Setting.plugin_restrict_timelog['allowed_tracker_ids']
          ids = Array(raw).flat_map { |v| v.to_s.split(/[,\s]+/) }.map!(&:to_i)
          issue&.tracker_id && ids.include?(issue.tracker_id)
        end

        # Không cho log nếu KHÔNG phải Epic/Story và tracker cũng không được phép
        def must_not_log_epic_or_story_unless_allowed
          return if allowed_tracker? || issue_id.blank?
          return if issue&.tracker&.name.in?(%w[Epic Story])

          errors.add(:issue, :invalid_tracker)
        end

        # spent_on phải nằm trong [start_date, due_date] nếu tracker không được phép
        def date_within_issue_range_unless_allowed
          return if allowed_tracker? || issue_id.blank? || spent_on.nil?

          if issue.start_date && spent_on < issue.start_date
            errors.add(:spent_on, :before_issue_start, start: issue.start_date.to_s)
          elsif issue.due_date && spent_on > issue.due_date
            errors.add(:spent_on, :after_issue_due,  due: issue.due_date.to_s)
          end
        end

        # Bỏ toàn bộ lỗi nếu tracker được phép
        def wipe_errors_if_allowed_tracker
          errors.clear if allowed_tracker?
        end
      end
    end
  end
end
