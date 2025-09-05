# frozen_string_literal: true

module TimeLimitGuard
  module PatchLoader
    def self.apply_patch
      require_dependency File.join(Rails.root, 'app/models/time_entry.rb')
      TimeEntry.include(TimeLimitGuard::TimeEntryPatch) unless TimeEntry < TimeLimitGuard::TimeEntryPatch
    end
  end
end
