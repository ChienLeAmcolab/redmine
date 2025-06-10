# redmine_dashboard/config/routes.rb
RedmineApp::Application.routes.draw do
  get  'projects/:project_id/dashboard',          to: 'dashboard#index',                  as: :project_dashboard
  get  'dashboard',                               to: 'dashboard#global',                 as: :global_dashboard

  get  'projects/:project_id/dashboard_settings', to: 'project_dashboard_settings#edit',   as: :edit_project_dashboard_settings
  put  'projects/:project_id/dashboard_settings', to: 'project_dashboard_settings#update', as: :project_dashboard_settings
end
