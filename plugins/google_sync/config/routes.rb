# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  post 'projects/:id/sync_effort', to: 'efforts#sync_project', as: 'sync_effort'
end
