require 'redmine'

# Simple plugin that exposes a new screen for quickly logging time spent on
# multiple issues at once.  Users with permission to log time can browse a
# filtered list of their assigned issues, enter hours and comments inline and
# submit them as a batch.  The list can be filtered by project, tracker or
# due date and defaults the spent_on date to the current date.

Redmine::Plugin.register :quick_time_entries do
  name 'Quick Time Entries'
  author 'Your Name'
  description 'Provides a screen to quickly log spent time for multiple tasks'
  version '1.0.0'
  url 'https://example.com/quick_time_entries'
  author_url 'https://example.com'

  # Require at least Redmine 6.0.0. The plugin should work with later
  # versions as well but has only been tested against 6.0.0.
  requires_redmine :version_or_higher => '6.0.0'

  # Define a permission for viewing and creating quick time entries.  We rely
  # on the built‑in :log_time permission to actually create time entries so
  # we don’t introduce any additional security surface.  Users must be
  # authenticated in order to access this screen.
  project_module :quick_time_entries do
    permission :quick_time_entries,
               { :quick_time_entries => [:index, :create] },
               :require => :loggedin
  end

  # Add a menu item to the top menu so users can easily access the screen.
  # The caption uses a translation key defined in the plugin’s locale file.
  menu :top_menu, :quick_time_entries,
       { :controller => 'quick_time_entries', :action => 'index' },
       # Use the namespaced translation key defined in the plugin locale files
       :caption => :quick_time_entries_label_quick_time_entries,
       :if => Proc.new { User.current.logged? }
end