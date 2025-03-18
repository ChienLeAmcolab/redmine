namespace :redmine do
  desc <<~DESC
    Gửi email cảnh báo cho người dùng nếu tổng số giờ log của ngày hôm qua nhỏ hơn 8 giờ
    và cài đặt cảnh báo đã được bật.
    
    Task này nên được lên lịch chạy vào lúc 8:00 sáng mỗi ngày để nhắc nhở người dùng.
    
    Các tùy chọn:
      * dry_run - In danh sách người nhận ra console thay vì gửi email.
    
    Ví dụ:
      rake redmine:time_alert RAILS_ENV="production"
      rake redmine:time_alert dry_run=1 RAILS_ENV="production"
  DESC
  task time_alert: :environment do
    dry_run = ENV['dry_run']

    User.where(status: User::STATUS_ACTIVE).find_each do |user|
      if user.need_time_alert?
        if dry_run
          $stdout.puts "#{user.name} <#{user.mail}>"
        else
          TimeAlertMailer.time_alert_notification(user).deliver_now
        end
      end
    end
  end
end
