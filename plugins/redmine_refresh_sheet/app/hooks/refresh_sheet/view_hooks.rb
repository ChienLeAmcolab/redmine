# plugins/redmine_refresh_sheet/app/hooks/view_hooks.rb
module RefreshSheet
  class ViewHooks < Redmine::Hook::ViewListener
    # Chèn partial vào sidebar của project show page
    render_on :view_projects_show_right, partial: 'projects/refresh_sheet'
  end
end
