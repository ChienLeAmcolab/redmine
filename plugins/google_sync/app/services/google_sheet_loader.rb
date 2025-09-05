require 'json'

class GoogleSheetLoader
  def self.load_json_data
    file_path = Rails.root.join('storage', 'google_sheet', 'output.json')
    raw_data = JSON.parse(File.read(file_path))
    return [] if raw_data.blank?

    headers = raw_data.first
    rows = raw_data[1..]

    rows.map do |row|
      headers.zip(row).to_h
    end
  rescue => e
    Rails.logger.error("Failed to load Google Sheet JSON: #{e.message}")
    []
  end
end
