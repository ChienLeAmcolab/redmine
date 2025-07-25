module TaskDoneStatusPatch
  def self.included(base)
    base.class_eval do
      before_validation :enforce_done_ratio_for_status
      validate :validate_done_forced_status
    end
  end

  private
  def enforce_done_ratio_for_status
    if will_save_change_to_status_id?
      new_name = IssueStatus.find(status_id).name
      forced = Setting.plugin_redmine_task_done['forced_statuses'].to_s.split(',').map(&:strip)
      self.done_ratio = 100 if forced.include?(new_name)
    end
  end

  def validate_done_forced_status
    forced = Setting.plugin_redmine_task_done['forced_statuses'].to_s.split(',').map(&:strip)
    if forced.include?(status.name) && done_ratio != 100
      errors.add(:done_ratio, "must be 100% when status is '#{status.name}'")
    end
  end
end
