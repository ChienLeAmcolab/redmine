class ShareLinkHook < Redmine::Hook::ViewListener
  # Chèn nút vào trang issue (dưới bảng chi tiết)
  render_on :view_issues_show_details_bottom, partial: 'share_link/button_issue'
  # Chèn nút vào trang dự án (cột trái, dưới mô tả)
  render_on :view_projects_show_left, partial: 'share_link/button_project'
end
