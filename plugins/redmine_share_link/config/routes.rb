# plugins/redmine_share_link/config/routes.rb
RedmineApp::Application.routes.draw do
  get 'share/issue/:id', to: 'share#issue', as: 'share_issue'
  get 'share/project/:id', to: 'share#project', as: 'share_project'
end
