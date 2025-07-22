# plugins/redmine_leave_automator/app/mailers/leave_mailer.rb
class LeaveMailer < Mailer
  default content_type: 'text/plain'
  prepend_view_path File.expand_path('../../views', __dir__)
  # user: User, issue: Issue, total_hours: Float, leave_period_text: String
  def notification(user, issue, total_hours, leave_period_text = nil)
    @user = user
    @issue = issue
    @project = issue.project
    @total_hours = total_hours
    @leave_period_text = leave_period_text

    # Lấy subject template từ settings và thay placeholder đơn giản
    raw_subject = Setting.plugin_redmine_leave_automator['email_subject_template']
    subject = raw_subject
                .gsub('{{project.name}}', @project.name)
                .gsub('{{user.name}}', @user.name)
                .gsub('{{spent_on}}', Date.today.strftime('%d/%m/%Y'))
    @mail = mail(
      to: recipients_list,
      subject: subject
    )
    @mail
  end

  private

  def recipients_list
    base = []
    base += Setting.plugin_redmine_leave_automator['hr_emails'].to_s.split(',').map(&:strip)
    %w[cpo_email ceo_email].each { |k| base << Setting.plugin_redmine_leave_automator[k] }

    # Chỉ lấy những member có role cho phép :manage_project
    managers = @project.members.includes(:roles)
                       .select { |m| m.roles.any? { |r| r.allowed_to?(:manage_project) } }
                       .map { |m| m.user.mail }

    (base + managers).compact.uniq
  end
end
