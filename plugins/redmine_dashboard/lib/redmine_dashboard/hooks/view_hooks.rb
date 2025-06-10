module RedmineDashboard
  module Hooks
    class ViewHooks < Redmine::Hook::ViewListener
      render_on :view_projects_show_right, partial: 'dashboard/project_overview'
    end
  end
end
