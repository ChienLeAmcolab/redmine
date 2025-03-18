class TimeAlertMailer < ActionMailer::Base
  def time_alert_notification(user)
    @user = user
    @logged_hours = user.time_logged_last_working_day
    mail :to => user.mail,
         :subject => I18n.t(:subject_time_alert_notification, default: "Thông báo: Bạn chưa log đủ 8h ngày hôm qua")
  end
end
