# frozen_string_literal: true

# This hook injects JavaScript into the issue edit form to hide a specified
# status option when the logged in user already has a configurable number of
# issues with that status.  The count is performed server‑side in the hook
# using Redmine's Issue model.  It does not enforce any restriction on the
# backend – only the UI is changed.  The user can still circumvent the UI via
# the API or other means, but this helps guide them during normal usage.

module PreventStatusUpdateJsOnly
  module Hooks
    class ViewHooks < Redmine::Hook::ViewListener
      # Hook triggered at the bottom of the issue details form.  We return
      # HTML containing a <script> tag; Redmine will insert this into the page
      # at render time【714512290547235†L108-L117】.
      def view_issues_form_details_bottom(context = {}) # rubocop:disable Metrics/MethodLength
        issue = context[:issue]
        return '' unless issue

        # Retrieve settings
        settings = Setting.plugin_prevent_status_update_js_only || {}
        blocked_status_id = settings['blocked_status_id'].to_s
        limit_per_user    = (settings['limit_per_user'].presence || 3).to_i

        # Do nothing if no status configured
        return '' if blocked_status_id.blank?

        # Parse excluded trackers; ensure we have an array of strings
        excluded_tracker_ids = settings['excluded_tracker_ids'] || []
        excluded_tracker_ids = [excluded_tracker_ids] unless excluded_tracker_ids.is_a?(Array)
        excluded_tracker_ids = excluded_tracker_ids.map(&:to_s).reject(&:blank?)

        # Skip if this issue's tracker is excluded
        return '' if issue.tracker && excluded_tracker_ids.include?(issue.tracker_id.to_s)

        # Count the number of issues assigned to the current user that already have
        # the blocked status.  We consider assigned_to only; if the issue has no
        # assignee, we use the current user as the effective assignee.  We do
        # not include this issue in the count if it already has the blocked status.
        user_id = issue.assigned_to_id || (User.current && User.current.id)
        count = 0
        if user_id
          count = Issue.where(status_id: blocked_status_id, assigned_to_id: user_id).count
          if issue.persisted? && issue.status_id.to_s == blocked_status_id
            count -= 1
          end
        end

        # Only hide the option if the user has reached or exceeded the limit and this
        # issue is not currently in the blocked status.  Otherwise we want to allow
        # the user to select/deselect the status for existing issues.
        should_hide = (count >= limit_per_user) && (issue.status_id.to_s != blocked_status_id)

        # Build JS snippet to disable and hide the option in the status select
        js = if should_hide
               <<~JAVASCRIPT
                 (function() {
                   var select = document.getElementById('issue_status_id');
                   if (!select) { return; }
                   var opt = select.querySelector('option[value="#{blocked_status_id}"]');
                   if (opt) {
                     opt.disabled = true;
                     opt.hidden   = true;
                   }
                 })();
               JAVASCRIPT
             else
               ''
             end

        return '' if js.blank?

        # Wrap JS in script tag and return.  Using raw HTML (string) is acceptable
        # for view hooks【714512290547235†L108-L117】.
        "<script>#{js}</script>"
      end
    end
  end
end