require 'redmine'

# Load patches and hooks
require_dependency File.expand_path('patches/issue_patch', __dir__)
require_dependency File.expand_path('patches/issues_controller_patch', __dir__)
require_dependency File.expand_path('lib/task_done_hooks', __dir__)

Redmine::Plugin.register :redmine_task_done do
  name 'Task Done Ratio Enforcer'
  author 'Your Name'
  description 'Enforce and validate % Done and disable edits for forced statuses via view hook JS injection'
  version '0.5.0'

  settings default: {
    'forced_statuses' => 'Closed,Test done',
    'custom_statuses' => 'Reject'
  },
           partial: 'settings/task_done_settings'
end

Rails.configuration.to_prepare do
  # Apply model and controller patches
  Issue.send(:include, TaskDoneStatusPatch) unless Issue.include?(TaskDoneStatusPatch)
  IssuesController.prepend(IssuesControllerQuickPatch) unless IssuesController.ancestors.include?(IssuesControllerQuickPatch)
end
