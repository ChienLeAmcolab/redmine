# plugins/redmine_refresh_sheet/app/controllers/refresh_sheet_controller.rb
require 'net/http'
require 'uri'

class RefreshSheetController < ApplicationController
  before_action :find_project
  before_action :authorize

  # GET /refresh_sheet/confirm?project_id=...
  # Hiển thị trang confirm
  def confirm
    render 'projects/refresh_sheet_confirm'
  end

  # GET /refresh_sheet/execute?project_id=...
  # Thực sự gọi Google Script và redirect về project
  def execute
    
    script_url = Setting.plugin_redmine_refresh_sheet['script_url'].to_s.strip

    if script_url.blank?
      flash[:error] = 'Google Script URL has not been configured!'
    else
      begin
        initial_url = "#{script_url}?id=#{@project.identifier}"
        response    = fetch_with_redirect(initial_url)
        data        = JSON.parse(response.body)

        if data['success']
          flash[:notice] = "#{data['message']}"
        else
          flash[:error]  = "#{data['error'] || 'Unknown error'}"
        end
      rescue => e
        flash[:error] = "Error when calling API: #{e.message}"
      end
    end

    
    session["refresh_sheet_last_#{@project.id}"] = Time.current
    redirect_to project_path(@project)
  end

  private

  # Sửa ở đây: lấy params[:project_id], fallback sang params[:id] nếu có
  def find_project
    id_param = params[:project_id] || params[:id]
    @project = Project.find(id_param)
  end

  # Phương thức hỗ trợ tự follow 302 redirect của Google Apps Script
  def fetch_with_redirect(uri_str, limit = 5)
    raise 'Too many redirect' if limit <= 0

    uri      = URI.parse(uri_str)
    response = Net::HTTP.get_response(uri)

    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      fetch_with_redirect(response['location'], limit - 1)
    else
      response.error!  # raise cho 4xx/5xx
    end
  end
end
