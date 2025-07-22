# plugins/redmine_leave_automator/app/mailers/leave_mailer.rb
class LeaveMailer < Mailer
  default content_type: 'text/plain'
  prepend_view_path File.expand_path('../../views', __dir__)
  # user: User, issue: Issue, total_hours: Float, leave_period_text: String
  def notification(user, issue, total_hours, leave_period_text = nil)
    @user              = user
    @issue             = issue
    @project           = issue.project
    @total_hours       = total_hours
    @leave_period_text = leave_period_text

    # Lấy subject template từ settings và thay placeholder đơn giản
    raw_subject = Setting.plugin_redmine_leave_automator['email_subject_template']
    subject = raw_subject
                .gsub('{{project.name}}', @project.name)
                .gsub('{{user.name}}',    @user.name)
                .gsub('{{spent_on}}',      Date.today.strftime('%d/%m/%Y'))
    binding.pry
    mail(
      to:      recipients_list,
      subject: subject
    )
    binding.pry
  end

  private

  def recipients_list
    list = []
    # HR, CPO, CEO
    list += Setting.plugin_redmine_leave_automator['hr_emails'].to_s.split(',').map(&:strip)
    %w[cpo_email ceo_email].each { |k| list << Setting.plugin_redmine_leave_automator[k] }
    # PMs và members
    @project.members.joins(:roles)
            .where(roles: { permissions: :manage_project })
            .each { |m| list << m.user.mail }
    @project.members.each { |m| list << m.user.mail }
    list.compact.uniq
  end
end
