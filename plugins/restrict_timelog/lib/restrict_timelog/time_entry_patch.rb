module RestrictTimelog
  module TimeEntryPatch
    def self.included(base)
      base.class_eval do
        validate :issue_must_be_present

        private

        def issue_must_be_present
          if issue_id.blank?
            errors.add(:issue, '    You must choose a Issue when recording time')
          end
        end
      end
    end
  end
end

# Gắn patch ngay khi file được load
TimeEntry.send(:include, RestrictTimelog::TimeEntryPatch)
