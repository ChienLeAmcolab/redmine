# plugins/redmine_meta_plugin/init.rb
require 'redmine'

Redmine::Plugin.register :redmine_meta_plugin do
  name 'Redmine Meta Plugin'
  author 'Chien LM Amcolab'
  description 'Meta plugin for Redmine'
  version '0.0.1'
  url 'http://amcolab/redmine_meta_plugin'
  author_url 'http://facebook.com/leminhchien'
end

require_dependency File.join(File.dirname(__FILE__), 'lib', 'redmine_meta_plugin', 'hooks')
