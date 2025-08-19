require 'redmine'

# Plugin: prevent_status_update_js_only
# This plugin hides a specific issue status in the edit form if the logged
# in user already has a configurable number (default 3) of issues in that
# status.  It operates purely on the front‑end by injecting JavaScript into
# the edit form via a view hook.  No backend validation is enforced.

Redmine::Plugin.register :prevent_status_update_js_only do
  name 'Prevent Status Update JS Only'
  author 'Chien LM'
  description 'Hide an issue status from the edit form when a user already has N issues in that status, with per‑tracker exclusions.'
  version '0.0.1'
  url 'https://example.com/prevent_status_update_js_only'
  author_url 'https://example.com'

  # Require Redmine 6.0.0 or higher (Rails 7) to ensure proper hook support and
  # compatibility【714512290547235†L230-L232】.
  requires_redmine version_or_higher: '6.0.0'

  # Default settings: blocked_status_id (string), excluded_tracker_ids (array of strings), limit_per_user (integer).
  settings partial: 'settings/prevent_status_update_js_only_settings',
           default: {
             'blocked_status_id'   => '',
             'excluded_tracker_ids' => [],
             'limit_per_user'       => 3
           }
end

# Load our hook.  Use a to_prepare block so reloading in development reloads
# this file correctly.
Rails.configuration.to_prepare do
  require_dependency 'prevent_status_update_js_only/hooks/view_hooks'
end
