module IssuesControllerQuickPatch
  def edit
    super
    return unless request.xhr? && @issue&.saved_change_to_status_id?
    forced = Setting.plugin_redmine_task_done['forced_statuses'].to_s.split(',').map(&:strip)
    @issue.update_column(:done_ratio, 100) if forced.include?(@issue.status.name)
  end
end
