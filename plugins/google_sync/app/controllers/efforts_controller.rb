class EffortsController < ApplicationController
  helper :projects
  include ProjectsHelper

  before_action :find_project

  def sync_project
    project = Project.find(params[:id])

    begin
      creds = Rails.application.credentials.google_sheets

      json_key_str = creds[:json_key].to_json

      service = GoogleSheetsService.new(credentials_json_str: json_key_str)

      data = service.read_sheet(
        spreadsheet_id: creds[:spreadsheet_id],
        range: creds[:range]
      )
      service.save_to_file(data)

      sheet_data = GoogleSheetLoader.load_json_data
      SyncProjectEffortService.new(sheet_data).sync_single(project)

      flash[:notice] = "✅ Đã đồng bộ effort từ Google Sheet."
    rescue => e
      flash[:error] = "❌ Lỗi đồng bộ: #{e.message}"
    end

    redirect_to settings_project_path(project, tab: 'information')
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end
end
