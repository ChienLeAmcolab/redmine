class LeaveAutomatorController < ApplicationController
  before_action :require_login

  def new
    @project = Project.find_by(id: Setting.plugin_redmine_leave_automator['target_project_id'])
  end

  def create
    rp = leave_params

    # Validate ngày
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

    # Config
    project_id  = Setting.plugin_redmine_leave_automator['target_project_id'].to_i
    tracker_id  = Setting.plugin_redmine_leave_automator['leave_tracker_id'].to_i
    activity_id = Setting.plugin_redmine_leave_automator['leave_activity_id'].to_i
    non_working = Setting.non_working_week_days.map(&:to_i)

    hours_hash = rp[:hours] || {}   # {"YYYY-MM-DD"=>"4"/"8", ...}
    created_issues = []

    ActiveRecord::Base.transaction do
      (start_date..end_date).each do |d|
        next if non_working.include?(d.wday)

        hrs = hours_hash[d.to_s].to_f
        next if hrs <= 0

        issue = Issue.create!(
          project_id:      project_id,
          tracker_id:      tracker_id,
          author_id:       User.current.id,
          assigned_to_id:  User.current.id,
          subject:         "#{rp[:reason]} (#{d.strftime('%d/%m/%Y')})",
          description:     rp[:description].presence,
          start_date:      d,
          due_date:        d,
          estimated_hours: hrs
        )
        created_issues << issue

        TimeEntry.create!(
          project_id:  project_id,
          issue_id:    issue.id,
          user_id:     User.current.id,
          spent_on:    d,
          hours:       hrs,
          activity_id: activity_id
        )
      end
    end

    if created_issues.empty?
      flash.now[:error] = 'Không có ngày hợp lệ để tạo Log Leave.'
      return render :new
    end

    # Text hiển thị trong mail view
    leave_period_text = if start_date == end_date
                          h = hours_hash[start_date.to_s].to_f
                          "#{h <= Setting.plugin_redmine_leave_automator['half_day_hours'].to_f ? 'Nửa ngày' : 'Cả ngày'} #{start_date.strftime('%d/%m/%Y')}"
                        else
                          "Từ #{start_date.strftime('%d/%m/%Y')} đến #{end_date.strftime('%d/%m/%Y')}"
                        end

    # Gửi mail: dùng issue đầu tiên để phù hợp view @issue
    LeaveMailer.with(
      user:              User.current,
      issue:             created_issues.first,
      leave_period_text: leave_period_text
    ).notification.deliver_later

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
