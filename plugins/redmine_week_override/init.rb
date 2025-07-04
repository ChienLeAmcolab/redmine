# Plugin: redmine_week_override
# Name   : Redmine Week Override
# Version: 1.0.1
# Author : ChienLM Amcolab

require 'redmine'

Rails.configuration.to_prepare do
  # Đảm bảo Query đã được load trước khi patch
  require_dependency 'query'
  # Load patch của chúng ta
  require_dependency File.expand_path('lib/redmine_week_override/query_patch', __dir__)
end

Redmine::Plugin.register :redmine_week_override do
  name        'Redmine Week Override'
  author      'ChienLM Amcolab'
  description 'Make "This week" filter use Setting.start_of_week'
  version     '1.0.1'
  url         'https://github.com/ChienLM/redmine_week_override'
  author_url  'https://github.com/ChienLM'
end
