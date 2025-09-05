module GoogleSync
  module Hooks
    class ViewProjectsFormHook < Redmine::Hook::ViewListener
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper

      def view_projects_form(context = {})
        project = context[:project]
        user    = User.current

        max_estimated_cf = CustomField.find_by(name: 'Max Total Estimated')
        return ''.html_safe unless max_estimated_cf

        can_sync = user.admin? || project.allowed_to?(user, :edit_project)

        return ''.html_safe unless can_sync

        content_tag(:p, class: 'custom-field') do
          link_to '↻ Đồng bộ từ Google Sheet',
                  Rails.application.routes.url_helpers.sync_effort_path(project),
                  method: :post,
                  remote: false,
                  data: { confirm: 'Bạn có chắc muốn đồng bộ từ Google Sheet không?' },
                  class: 'icon icon-refresh',
                  style: 'margin-left: 10px;'
        end
      end
    end
  end
end
