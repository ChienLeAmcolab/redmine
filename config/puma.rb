# config/puma.rb

directory '/home/deploy/redmine'
rackup "/home/deploy/redmine/config.ru"
environment 'production'

pidfile "/home/deploy/redmine/tmp/pids/puma.pid"
state_path "/home/deploy/redmine/tmp/pids/puma.state"

stdout_redirect '/home/deploy/redmine/log/puma.stdout.log', '/home/deploy/redmine/log/puma.stderr.log', true

bind "tcp://0.0.0.0:3000"

workers 2
threads 1, 5

# preload_app!

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.establish_connection
end



