require 'redmine'

module TimeLimitGuard; end

require_relative 'lib/time_limit_guard/patch_loader'

Redmine::Plugin.register :redmine_time_entry_limit do
  name 'Redmine Time Entry Limit'
  author 'Tommy'
  description 'Plugin to prevent logging time over Max Total Estimated'
  version '0.0.1'
end

Rails.application.config.after_initialize do
  require_dependency File.join(Rails.root, 'app/models/time_entry.rb')
  TimeLimitGuard::PatchLoader.apply_patch
end
