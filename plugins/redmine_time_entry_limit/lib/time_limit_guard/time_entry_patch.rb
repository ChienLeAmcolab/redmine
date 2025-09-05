# frozen_string_literal: true

module TimeLimitGuard
  module TimeEntryPatch
    extend ActiveSupport::Concern

    included do
      validate :validate_time_entry_limit_guard
    end

    def validate_time_entry_limit_guard
      return unless project && hours && user

      max_custom_field = project.custom_field_values.detect do |cf|
        cf.custom_field.name == 'Max Total Estimated'
      end

      if max_custom_field && (max_value = max_custom_field.value.to_f) > 0
        spent = TimeEntry.where(project_id: project.id).sum(:hours)
        if spent + hours > max_value
          errors.add(:hours, "exceeds maximum allowed (#{max_value}h)")
        end
      end
    end
  end
end
