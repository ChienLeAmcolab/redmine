module RedmineLeaveAutomator
  class ViewHooks < Redmine::Hook::ViewListener
    # Thêm tab “Log Leave” cạnh My account
    render_on :view_my_account_contextual, partial: 'hooks/log_leave_tab'

    #
    # Insert leave alerts on every page. This hook method is called when
    # Redmine renders the base layout. It looks for future leave issues created
    # by the plugin (one issue per day) whose authors share at least one active
    # project with the current user. The alerts are presented as dismissable
    # banners at the top of the page. Users can dismiss an alert and it will
    # remain hidden until the next day, avoiding repetitive notifications while
    # still reminding colleagues during the leave period.
    #
    def view_layouts_base_content(context = {})
      # Only logged in users should see alerts
      return '' unless User.current&.logged?

      user = User.current
      # Read configuration: project used to store leave issues and leave tracker
      leave_project_id = Setting.plugin_redmine_leave_automator['target_project_id'].to_i
      tracker_id       = Setting.plugin_redmine_leave_automator['leave_tracker_id'].to_i
      return '' if leave_project_id.zero? || tracker_id.zero?

      # Today's date; we only care about leave issues from today onward
      today = Date.current
      # Fetch leave issues (one per day) not created by the current user
      leave_issues = Issue.where(project_id: leave_project_id, tracker_id: tracker_id)
                          .where('start_date >= ?', today)
                          .where.not(author_id: user.id)

      # Determine the set of active projects the current user is involved in
      # (excluding the project storing leave issues). Alerts are only shown when
      # both the current user and the leave author share at least one of these.
      current_project_ids = user.projects.where(status: Project::STATUS_ACTIVE).pluck(:id)
      current_project_ids -= [leave_project_id]

      alerts = []
      leave_issues.each do |issue|
        author_project_ids = issue.author.projects.where(status: Project::STATUS_ACTIVE).pluck(:id)
        # Only alert if they share at least one project (excluding the leave
        # project). This prevents sending company‑wide alerts for people with no
        # overlap.
        next if (author_project_ids & current_project_ids).empty?
        alerts << issue
      end

      return '' if alerts.empty?

      # Render the partial. `render_to_string` is used because view hooks need
      # to return raw HTML. We pass the list of issues to the partial.
      context[:controller].send(:render_to_string, partial: 'hooks/leave_alert', locals: { alerts: alerts })
    end
  end
end
