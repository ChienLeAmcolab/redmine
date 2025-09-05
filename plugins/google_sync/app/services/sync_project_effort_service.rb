class SyncProjectEffortService
  def initialize(sheet_data)
    @sheet_data = sheet_data
    @po_cf = CustomField.find_by(name: 'PO Number')
    @pj_cf = CustomField.find_by(name: 'Project Number')
    @max_hours_cf = CustomField.find_by(name: 'Max Total Estimated')
  end

  def sync
    Project.active.each do |project|
      sync_single(project)
    end
  end

  def sync_single(project)
    po_number = custom_field_value(project, @po_cf)
    pj_number = custom_field_value(project, @pj_cf)

    if po_number.blank? && pj_number.blank?
      raise "Không thể đồng bộ vì PO Number và ProjectNo đều trống cho project '#{project.name}'"
    end

    matched_row = @sheet_data.find do |row|
      row_po = row['PO Number'].to_s.strip
      row_pj = row['Project Number'].to_s.strip

      next if row_po.blank? && row_pj.blank?

      row_po == po_number.to_s.strip || row_pj == pj_number.to_s.strip
    end

    unless matched_row
      raise "Không tìm thấy dòng nào trong sheet khớp với PO Number hoặc ProjectNo của project '#{project.name}'"
    end

    total_effort = parse_number(matched_row['Total Allocated Efforts (mh)'])
    raise "Không đọc được số giờ effort từ dòng sheet" if total_effort.nil?

    update_custom_field(project, @max_hours_cf, total_effort)
  end

  private

  def custom_field_value(project, custom_field)
    project.custom_field_value(custom_field)
  end

  def update_custom_field(project, custom_field, value)
    project.custom_field_values = { custom_field.id => value }
    project.save!
  end

  def parse_number(str)
    return nil unless str
    str.to_s.gsub(",", "").to_f
  end
end
