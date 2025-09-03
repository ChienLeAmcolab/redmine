# frozen_string_literal: true

# Routes for the QuickTimeEntries plugin.  We register two routes – one for
# displaying the list of issues and one for submitting time entries.  Both
# routes are defined at the top level to avoid clashing with existing
# controllers.  They use GET and POST respectively.

RedmineApp::Application.routes.draw do
  # Display the quick time entry form
  get 'quick_time_entries', :to => 'quick_time_entries#index', :as => 'quick_time_entries'
  # Accept batch submission of time entries
  post 'quick_time_entries', :to => 'quick_time_entries#create'
end