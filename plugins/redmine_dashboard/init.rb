# redmine_dashboard/init.rb
require 'redmine'
plugin_root = File.dirname(__FILE__)
lib_path  = File.join(plugin_root, 'lib')
app_path  = File.join(plugin_root, 'app')
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require_dependency File.join(plugin_root, 'lib', 'redmine_dashboard', 'hooks', 'view_hooks')

Redmine::Plugin.register :redmine_dashboard do
  name 'Redmine Dashboard'
  author 'Lê Minh Chiến'
  description 'Adds a Dashboard tab and overview iframe with configurable URL'
  version '0.1.0'
  url 'https://amcolab.vn'

  # Permissions
  permission :view_dashboard,
             { dashboard: [:index] },
             global: true
  permission :configure_project_dashboard, { project_dashboard_settings: [:edit, :update] },
             require: :member


  # Global default URL setting
  settings default: { 'default_url' => '' },
           partial: 'settings/dashboard_settings'
end

# Add Dashboard tab in project menu
Redmine::MenuManager.map :project_menu do |menu|
  menu.push :dashboard,
            { controller: 'dashboard', action: 'index' },
            param: :project_id,
            caption: Proc.new { I18n.t(:label_dashboard) },
            after: :activity,
            if:    Proc.new { |project| User.current.allowed_to?(:view_dashboard, project) }
end

# Add Dashboard Settings tab in project settings menu
Redmine::MenuManager.map :project_settings_menu do |menu|
  menu.push :dashboard_settings,
            { controller: 'project_dashboard_settings', action: 'edit' },
            param: :project_id,
            caption: Proc.new { I18n.t(:label_dashboard_settings) },
            after: :repositories,
            if:    Proc.new { |project| User.current.allowed_to?(:configure_project_dashboard, project) }
end
Redmine::MenuManager.map :application_menu do |menu|
  menu.push :global_dashboard,
            { controller: 'dashboard', action: 'global' },
            caption: Proc.new { I18n.t(:label_dashboard) },
            after:   :projects,
            if:      Proc.new { |project|
              project.nil? &&
                User.current.allowed_to?(:view_dashboard, nil, global: true)
            }
end
