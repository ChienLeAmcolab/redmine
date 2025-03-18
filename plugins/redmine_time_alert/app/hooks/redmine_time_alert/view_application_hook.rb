module RedmineTimeAlert
  class ViewApplicationHook < Redmine::Hook::ViewListener
    render_on :view_layouts_base_html_head, :partial => 'time_alert/alert_notification'
  end
end
