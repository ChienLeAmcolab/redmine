require 'singleton'

class ProjectMaxHoursService
  include Singleton

  def initialize
    load_data
  end

  def get(project_id)
    @data[project_id.to_s]
  end

  def load_data
    path = Rails.root.join("storage", "google_sheet", "output.json")
    json = JSON.parse(File.read(path))
    @data = {}

    json.each do |row|
      project_identifier = row[0]&.strip
      estimate_hour_str = row[10]
      next if project_identifier.blank? || estimate_hour_str.blank?

      project = Project.find_by_identifier(project_identifier)
      next unless project

      @data[project.id.to_s] = estimate_hour_str.to_f
    end
  end

  def reload!
    load_data
  end
end
