class LeaveMailer < Mailer
  # Giữ nguyên view: dùng @user, @issue, @leave_period_text
  def notification(user, issue, leave_period_text)
    @user              = user
    @issue             = issue
    @leave_period_text = leave_period_text

    mail(
      to: recipients_for(user),
      subject: "[#{@issue.project.name}][Leave] #{@user.name} - #{@leave_period_text}"
    )
  end

  private

  def recipients_for(user)
    list = []
    list += Setting.plugin_redmine_leave_automator['hr_emails'].to_s.split(',').map(&:strip)
    list << Setting.plugin_redmine_leave_automator['cpo_email']
    list << Setting.plugin_redmine_leave_automator['ceo_email']

    pm_role_ids = Setting.plugin_redmine_leave_automator['pm_role_ids']
                         .to_s.split(',').map(&:strip).map(&:to_i)

    # PMs + members các dự án active mà user tham gia
    projects = user.projects.where(status: Project::STATUS_ACTIVE)
    pm_emails = projects.flat_map do |p|
      p.members.joins(:roles)
        .where(member_roles: { role_id: pm_role_ids })
       .map { |m| m.user.mail }
    end

    (list + pm_emails).compact.uniq
  end
end
