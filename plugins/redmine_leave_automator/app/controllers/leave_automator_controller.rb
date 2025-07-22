class LeaveAutomatorController < ApplicationController
  before_action :require_login

  def new
    @project = Project.find_by(id: Setting.plugin_redmine_leave_automator['target_project_id'])
  end

  def create
    rp = leave_params

    # --- Validate ngày ---
    if rp[:start_date].blank? || rp[:end_date].blank?
      flash.now[:error] = 'Bạn phải chọn Ngày bắt đầu và Ngày kết thúc.'
      return render :new
    end
    start_date = Date.parse(rp[:start_date]) rescue nil
    end_date   = Date.parse(rp[:end_date])   rescue nil
    if start_date.nil? || end_date.nil?
      flash.now[:error] = 'Định dạng ngày không hợp lệ.'
      return render :new
    end
    if end_date < start_date
      flash.now[:error] = 'Ngày kết thúc không thể trước Ngày bắt đầu.'
      return render :new
    end

    # --- Config ---
    project_id   = Setting.plugin_redmine_leave_automator['target_project_id'].to_i
    tracker_id   = Setting.plugin_redmine_leave_automator['leave_tracker_id'].to_i
    activity_id  = Setting.plugin_redmine_leave_automator['leave_activity_id'].to_i
    hours_full   = Setting.plugin_redmine_leave_automator['full_day_hours'].to_f
    hours_half   = Setting.plugin_redmine_leave_automator['half_day_hours'].to_f
    non_working  = Setting.non_working_week_days.map(&:to_i) # [0..6]

    # Nếu user chọn 1 lần cho cả kỳ (half/full)
    default_day_type = rp[:day_type] # 'half' hoặc 'full'
    # Hoặc từng ngày: { '2025-07-18' => 'half', ... }
    day_type_hash    = rp[:day_type_by_date] || {}

    created_issues = []

    ActiveRecord::Base.transaction do
      (start_date..end_date).each do |d|
        next if non_working.include?(d.wday)

        # Xác định giờ nghỉ cho ngày d
        type = (day_type_hash[d.to_s] || default_day_type).to_s
        hours = type == 'half' ? hours_half : hours_full

        # Tạo Issue cho từng ngày
        issue = Issue.create!(
          project_id:      project_id,
          tracker_id:      tracker_id,
          author_id:       User.current.id,
          assigned_to_id:  User.current.id,
          subject:         "#{rp[:reason]} (#{d.strftime('%d/%m/%Y')})",
          description:     rp[:description].presence,
          start_date:      d,
          due_date:        d,
          estimated_hours: hours
        )
        created_issues << issue

        # Tạo TimeEntry cho từng ngày
        TimeEntry.create!(
          project_id:  project_id,
          issue_id:    issue.id,
          user_id:     User.current.id,
          spent_on:    d,
          hours:       hours,
          activity_id: activity_id
        )
      end
    end

    # Gửi mail tóm tắt (tùy mailer của bạn, truyền mảng issues)
    LeaveMailer
      .notification(User.current, created_issues)
      .deliver_later

    flash[:notice] = 'Log Leave Success!'
    redirect_to my_page_path

  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = e.record.errors.full_messages.join(', ')
    render :new
  end

  private

  def leave_params
    # Cho phép hash động dạng hours[YYYY-MM-DD] => '4'/'8'  . :contentReference[oaicite:1]{index=1}
    params.permit(:reason, :start_date, :end_date, :description, hours: {})
  end
end
