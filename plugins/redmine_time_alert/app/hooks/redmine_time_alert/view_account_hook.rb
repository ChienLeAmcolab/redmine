module RedmineTimeAlert
  class ViewAccountHook < Redmine::Hook::ViewListener
    render_on :view_my_account_preferences, :partial => 'time_alert/my_account_preferences'
  end
end
