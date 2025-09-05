Redmine::Plugin.register :google_sync do
  name 'Google Sync plugin'
  author 'Hoàng Ngọc Hòa'
  description 'Đồng bộ dữ liệu từ Google Sheets vào hệ thống'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end

require_dependency File.expand_path('../lib/google_sync/hooks/view_projects_form_hook', __FILE__)

require_dependency File.expand_path('../app/controllers/efforts_controller', __FILE__)

require_dependency File.expand_path('../app/services/sync_project_effort_service', __FILE__)
require_dependency File.expand_path('../app/services/google_sheet_loader', __FILE__)
require_dependency File.expand_path('../app/services/google_sheet_normalizer', __FILE__)

Rails.application.config.assets.precompile += %w(google_sync.css)
 