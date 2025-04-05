class ViewsLayoutsHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = {})
    # return javascript_include_tag(:share_link, :plugin => 'redmine_share_link') +
    #   stylesheet_link_tag(:share_link, :plugin => 'redmine_share_link')
  end
end
