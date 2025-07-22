module RedmineLeaveAutomator
  class ViewHooks < Redmine::Hook::ViewListener
    # Thêm tab “Log Leave” cạnh My account
    render_on :view_my_account_contextual, partial: 'hooks/log_leave_tab'
  end
end
