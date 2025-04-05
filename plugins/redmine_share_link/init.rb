# plugins/redmine_share_link/init.rb
require 'redmine'
Redmine::Plugin.register :redmine_share_link do
  name 'Redmine Share Link'
  author 'Le Minh Chien Amcolab'
  description 'Plugin tạo liên kết chia sẻ cho issue/project (bao gồm Open Graph meta tags cho preview)'
  version '1.0.0'
  requires_redmine version_or_higher: '6.0.0'
  settings default: { 'share_secret' => 'ThayDoiSecretNay' }, partial: '' 
end

# Nạp hook view để chèn nút chia sẻ vào giao diện
if (Rails.configuration.respond_to?(:autoloader) && Rails.configuration.autoloader == :zeitwerk) || Rails.version > '7.0'
  Rails.autoloaders.each { |loader| loader.ignore(File.dirname(__FILE__) + '/lib') }
end
require File.dirname(__FILE__) + '/lib/share_link_hook'
require File.dirname(__FILE__) + '/lib/views_layouts_hook'
