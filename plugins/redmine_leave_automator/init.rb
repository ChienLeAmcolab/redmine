require 'redmine'
require_relative 'lib/redmine_leave_automator/version'

Redmine::Plugin.register :redmine_leave_automator do
  menu :top_menu, :leave_automator, { controller: 'leave_automator', action: 'new' }, caption: 'Fast Log Leave', if: Proc.new { User.current.logged? }
  name        'Leave Automator'
  author      'Lê Minh Chiến Amcolab'
  description 'Tự động tạo Issue + TimeEntry khi Log Leave và gửi email thông báo'
  version     RedmineLeaveAutomator::Version::STRING
  settings default: {
    'target_project_id'      => '',
    'leave_tracker_id'       => '',
    'leave_activity_id'      => '',
    'full_day_hours'         => '8',
    'half_day_hours'         => '4',
    'hr_emails'              => '',
    'cpo_email'              => '',
    'ceo_email'              => '',
    'email_subject_template' => '[{{project.name}}][Leave] {{user.name}} trên {{spent_on}}',
    'email_body_template'    => <<~BODY
      Họ & tên: {{ user.name }}

      Lý do xin nghỉ: {{ issue.subject }}

      Thời gian xin nghỉ: {{ leave_period_text }}

      Tổng số giờ nghỉ: {{ total_hours }}

      {% if issue.description and issue.description != "" %}
      Dự án đang thực hiện + tiến độ:
      {{ issue.description }}
      {% endif %}
    BODY
  }, partial: 'settings/settings'
end

Rails.configuration.to_prepare do
  require_dependency 'redmine_leave_automator/view_hooks'
  Mailer.prepend_view_path File.expand_path('../../app/views', __FILE__)
end

