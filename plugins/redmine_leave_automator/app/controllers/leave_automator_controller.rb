class LeaveAutomatorController < ApplicationController
  before_action :require_login

  def new
    @project = Project.find_by(id: Setting.plugin_redmine_leave_automator['target_project_id'])
  end

  def create
    rp = leave_params

    # Server‑side validate ngày
    if rp[:start_date].blank? || rp[:end_date].blank?
      flash.now[:error] = 'Bạn phải chọn Ngày bắt đầu và Ngày kết thúc.'
      return render :new
    end

    start_date = Date.parse(rp[:start_date])
    end_date   = Date.parse(rp[:end_date])
    if end_date < start_date
      flash.now[:error] = 'Ngày kết thúc không thể trước Ngày bắt đầu.'
      return render :new
    end

    # Tính tổng giờ dự kiến
    hours_hash   = rp[:hours] || {}
    total_hours  = hours_hash.values.map(&:to_f).sum

    # Chuỗi mô tả khoảng nghỉ
    leave_period_text = build_leave_period_text(start_date, end_date, hours_hash)
    # Tạo Issue
    issue = Issue.new(
      project_id:      Setting.plugin_redmine_leave_automator['target_project_id'].to_i,
      tracker_id:      Setting.plugin_redmine_leave_automator['leave_tracker_id'].to_i,
      author_id:       User.current.id,
      assigned_to_id:  User.current.id,
      subject:         rp[:reason],
      description:     rp[:description].presence,
      start_date:      start_date,
      due_date:        end_date,
      estimated_hours: total_hours
    )
    issue.save!

    # Tạo TimeEntry cho từng ngày
    activity_id = Setting.plugin_redmine_leave_automator['leave_activity_id'].to_i
    non_working = Setting.non_working_week_days.map(&:to_i)
    hours_hash.each do |date_str, hrs|
      date = Date.parse(date_str) rescue next
      next if non_working.include?(date.wday)

      TimeEntry.create!(
        project_id:  issue.project_id,
        issue_id:    issue.id,
        user_id:     User.current.id,
        spent_on:    date,
        hours:       hrs.to_f,
        activity_id: activity_id
      )
    end
    # Gửi mail
    LeaveMailer
      .notification(
        User.current,
        issue,
        total_hours,
        leave_period_text
      )
      .deliver_now

    flash[:notice] = 'Log Leave thành công!'
    redirect_to my_page_path
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = e.record.errors.full_messages.join(', ')
    render :new
  end

  private

  def leave_params
    params.permit(
      :reason,
      :start_date,
      :end_date,
      :description,
      hours: {}
    )
  end

  def build_leave_period_text(start_date, end_date, hours_hash)
    if start_date == end_date
      h = hours_hash[start_date.to_s].to_f
      period = (h < Setting.plugin_redmine_leave_automator['full_day_hours'].to_f) ? 'Nửa ngày' : 'Cả ngày'
      "#{period} #{start_date.strftime('%d/%m/%Y')}"
    else
      "Từ #{start_date.strftime('%d/%m/%Y')} đến #{end_date.strftime('%d/%m/%Y')}"
    end
  end

end
