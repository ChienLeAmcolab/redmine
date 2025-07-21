RedmineApp::Application.routes.draw do
  resource :leave_automator, only: [:new, :create], controller: 'leave_automator'
end
