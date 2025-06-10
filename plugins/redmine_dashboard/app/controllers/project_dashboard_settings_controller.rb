# app/controllers/project_dashboard_settings_controller.rb
class ProjectDashboardSettingsController < ApplicationController
  before_action :find_project
  before_action :authorize, only: [:edit, :update]

  def edit
    @global_default = Setting.plugin_redmine_dashboard['default_url']
    cfv             = @project.custom_field_values.detect { |v| v.custom_field.name == 'Dashboard URL' }
    @project_url    = cfv.try(:value)
  end

  def update
    url_value = params[:dashboard_url].presence
    cf        = ProjectCustomField.find_by_name('Dashboard URL')
    if cf
      if (cfv = @project.custom_field_values.detect { |v| v.custom_field_id == cf.id })
        cfv.value = url_value
        cfv.save
      else
        @project.custom_values.create(custom_field: cf, value: url_value)
      end
    end
    flash[:notice] = l(:notice_successful_update)
    redirect_to edit_project_dashboard_settings_path(@project)
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end
end
