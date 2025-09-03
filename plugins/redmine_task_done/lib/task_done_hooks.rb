module TaskDoneHooks
  class FormHook < Redmine::Hook::ViewListener
    # Inject inline JS at bottom of issue form to disable %done
    def view_issues_form_details_bottom(context = {})
      forced = Setting.plugin_redmine_task_done['forced_statuses'].to_s.split(',').map(&:strip)
      js = <<~JAVASCRIPT
        <script type="text/javascript">
        document.addEventListener('DOMContentLoaded', function() {
          function toggleDone() {
            var forced = #{forced.inspect};
            var status = document.getElementById('issue_status_id');
            var done = document.getElementById('issue_done_ratio');
            if (!status || !done) return;
            var text = status.options[status.selectedIndex].text;
            if (forced.includes(text)) {
              done.value = 100;
              done.disabled = true;
            } else {
              done.disabled = false;
            }
          }
          var status = document.getElementById('issue_status_id');
          if (status) {
            status.addEventListener('change', toggleDone);
            toggleDone();
          }
        });
        </script>
      JAVASCRIPT
      js.html_safe
    end
  end
end
