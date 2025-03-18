# redmine_time_alert/init.rb
require 'redmine'

TIME_ALERT_VERSION = '0.0.1'.freeze

plugin_root = File.dirname(__FILE__)
lib_path  = File.join(plugin_root, 'lib')
app_path  = File.join(plugin_root, 'app')

$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

# Load file patches và mailer
require_dependency 'patches/user_preference_patch'
require_dependency 'patches/user_patch'
# require_dependency File.join(plugin_root, 'app', 'mailers', 'time_alert_mailer')
require_dependency File.join(plugin_root, 'lib', 'patches', 'account_controller_patch')
require_dependency File.join(plugin_root, 'lib', 'patches', 'user_patch')
require_dependency File.join(plugin_root, 'lib', 'patches', 'user_preference_patch')


# Load the hooks from the folder has been placed Namespace correctly
require_dependency File.join(plugin_root, 'app', 'hooks', 'redmine_time_alert', 'view_account_hook')
require_dependency File.join(plugin_root, 'app', 'hooks', 'redmine_time_alert', 'view_application_hook')

Redmine::Plugin.register :redmine_time_alert do
  name "Redmine Time Alert plugin"
  author 'Le Minh Chien Amcolab'
  description 'Send email notifications and display warnings on Redmine if the user log is less than 8 hours yesterday'
  version 0.1
  url 'http://example.com/redmine_time_alert'
  author_url 'http://example.com'

  settings default: {
    'time_alert_email_enabled' => true,
    'time_alert_redmine_enabled' => true
  }, partial: 'settings/time_alert_settings'
end

if (Rails.configuration.respond_to?(:autoloader) && Rails.configuration.autoloader == :zeitwerk) || Rails.version > '7.0'
  Rails.autoloaders.each do |loader|
    loader.ignore(lib_path)
    loader.ignore(app_path)
  end
end

# Request the main file of the plugin (create this file if not available)
require File.join(plugin_root, 'lib', 'redmine_time_alert')
