require 'google/apis/sheets_v4'
require 'googleauth'
require 'json'
require 'fileutils'
require 'stringio'

class GoogleSheetsService
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

  def initialize(credentials_json_str:)
    @service = Google::Apis::SheetsV4::SheetsService.new

    json_io = StringIO.new(credentials_json_str)

    @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: json_io,
      scope: SCOPE
    )
  end

  def read_sheet(spreadsheet_id:, range:)
    response = @service.get_spreadsheet_values(spreadsheet_id, range)
    response.values
  end

  def save_to_file(data)
    folder_path = Rails.root.join('storage', 'google_sheet')
    FileUtils.mkdir_p(folder_path)

    full_path = File.join(folder_path, 'output.json')
    is_new = !File.exist?(full_path)

    File.open(full_path, 'w') do |f|
      f.write(JSON.pretty_generate(data))
    end

    if is_new
      Rails.logger.info("🆕 Tạo mới file output.json tại #{full_path}")
    else
      Rails.logger.info("♻️ Đã ghi đè file output.json tại #{full_path}")
    end

    full_path
  end
end
