# app/controllers/dashboard_controller.rb
require 'net/http'

class DashboardController < ApplicationController
  before_action :find_project
  before_action :authorize, only: [:index]
  skip_before_action :find_project, only: :global
  def index
    global_url = Setting.plugin_redmine_dashboard['default_url']
    cfv = @project.custom_field_values.detect { |v| v.custom_field.name == 'Dashboard URL' }
    project_url = cfv.try(:value)
    @dashboard_url = params[:url].presence || project_url.presence || global_url

    unless @dashboard_url.present?
      flash[:error] = l(:error_dashboard_url_not_set)
      redirect_to project_settings_path(@project)
    end
  end

  # Global dashboard
  def global
    @dashboard_url = Setting.plugin_redmine_dashboard['default_url']
    unless @dashboard_url.present?
      flash[:error] = l(:error_dashboard_url_not_set)
      redirect_to admin_plugins_path
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end
end
