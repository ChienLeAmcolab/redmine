# plugins/restrict_timelog/init.rb
require 'redmine'

Rails.configuration.to_prepare do
  # 1) Đảm bảo model gốc TimeEntry đã load
  require_dependency 'time_entry'
  # 2) Nạp file patch
  require_dependency File.expand_path('lib/restrict_timelog/time_entry_patch', __dir__)
end

Redmine::Plugin.register :restrict_timelog do
  name        'Restrict Timelog'
  author      'Your Name'
  description 'Chặn log time không chọn issue_id'
  version     '0.1.0'
end
