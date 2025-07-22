# app/mailers/leave_mailer.rb
class LeaveMailer < Mailer
  def notification
    @user              = params[:user]
    @issue             = params[:issue]
    @leave_period_text = params[:leave_period_text]

    mail(
      to: recipients_for(@user),
      subject: "[#{@issue.project.name}][Leave] #{@user.name} - #{@leave_period_text}"
    )
  end

  private

  def recipients_for(user)
    list = []
    list += Setting.plugin_redmine_leave_automator['hr_emails'].to_s.split(',').map(&:strip)
    list << Setting.plugin_redmine_leave_automator['cpo_email']
    list << Setting.plugin_redmine_leave_automator['ceo_email']

    projects = user.projects.where(status: Project::STATUS_ACTIVE)
    pm_emails = projects.flat_map do |p|
      p.members.joins(:roles)
       .where(roles: { permissions: :manage_project })
       .map { |m| m.user.mail }
    end
    member_emails = projects.flat_map { |p| p.members.map { |m| m.user.mail } }

    (list + pm_emails + member_emails).compact.uniq
  end
end
