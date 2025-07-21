# plugins/redmine_refresh_sheet/init.rb
require 'redmine'

Redmine::Plugin.register :redmine_refresh_sheet do
  name        'Redmine Refresh Sheet Plugin'
  author      'Lê Minh Chiến'
  description 'Thêm nút gọi Google Apps Script qua back-end proxy'
  version     '0.1.0'
  # Khai báo plugin settings, partial sẽ nằm ở app/views/settings/_refresh_sheet_settings.html.erb
  settings default: { 'script_url' => '' },
           partial: 'settings/refresh_sheet_settings'
  project_module :refresh_sheet do
    # define a single permission that covers both actions
    permission :refresh_sheet, { refresh_sheet: [:confirm, :execute] }, require: :loggedin
  end
end

# load hook và controller
# require_dependency File.expand_path('app/controllers/refresh_sheet_controller.rb', __dir__)
# require_dependency File.expand_path('app/hooks/view_hooks.rb',             __dir__)
