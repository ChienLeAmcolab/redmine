class TimeAlertMailer < ActionMailer::Base
  default from: "admin@amcolab.vn"

  def time_alert_notification(user)
    @user = user
    mail :to => user.mail,
         :subject => I18n.t(:subject_time_alert_notification, default: "Thông báo: Bạn chưa log đủ 8h ngày hôm qua")
  end
end
