# plugins/google_sync/app/services/google_sheet_normalizer.rb
class GoogleSheetNormalizer
  def self.normalize(raw_data)
    return [] if raw_data.blank? || raw_data.size < 2
    header = raw_data.first
    rows = raw_data[1..]
    rows.map { |row| Hash[header.zip(row)] }
  end
end
