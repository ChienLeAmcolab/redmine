module HtmlTitlePatch
  def html_title(*args)
    if args.empty? && defined?(@issue) && @issue.present?
      "#{@issue.subject} - #{@issue.project.name} - AMCOLAB Project Manager"
    else
      super
    end
  end
end

ApplicationHelper.prepend(HtmlTitlePatch)
