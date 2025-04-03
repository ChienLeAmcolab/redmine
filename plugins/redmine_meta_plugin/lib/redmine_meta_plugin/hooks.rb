# plugins/redmine_meta_plugin/lib/redmine_meta_plugin/hooks.rb
module RedmineMetaPlugin
  class Hooks < Redmine::Hook::ViewListener
    #Hook insert meta tags into the page <head> of the page
    def view_layouts_base_html_head(context = {})
      meta_tags = ""

      # If the current page is the issue page
      if context[:issue]
        issue = context[:issue]
        meta_tags << %(<meta property="og:title" content="#{h issue.subject}" />\n)
        if issue.description.present?
          meta_tags << %(<meta property="og:description" content="#{h issue.description}" />\n)
        end
        meta_tags << %(<meta property="og:type" content="article" />\n)
        meta_tags << %(<meta property="og:url" content="#{url_for(controller: 'issues', action: 'show', id: issue.id)}" />\n)

        # If the current page is the project page
      elsif context[:project]
        project = context[:project]
        meta_tags << %(<meta property="og:title" content="#{h project.name}" />\n)
        if project.description.present?
          meta_tags << %(<meta property="og:description" content="#{h project.description}" />\n)
        end
        meta_tags << %(<meta property="og:type" content="website" />\n)
        meta_tags << %(<meta property="og:url" content="#{url_for(controller: 'projects', action: 'show', id: project.identifier)}" />\n)
      end

      meta_tags.html_safe
    end

    private

    # Escape content for safety when render html
    def h(text)
      Rack::Utils.escape_html(text.to_s)
    end

    # The function supports to create absolute url
    def url_for(options = {})
      host = Rails.application.config.action_controller.asset_host || "http://amcolab.redmine.com"
      Rails.application.routes.url_for(options.merge(host: host))
    end
  end
end
