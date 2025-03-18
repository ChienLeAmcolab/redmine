if Redmine::Plugin.installed? 'redmine_time_alert'
  RedmineApp::Application.routes.draw do
    if Rails.env.development?
      mount LetterOpenerWeb::Engine, at: "/letter_opener"
    end
  end
end
