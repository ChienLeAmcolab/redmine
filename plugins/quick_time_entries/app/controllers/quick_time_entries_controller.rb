# frozen_string_literal: true

class QuickTimeEntriesController < ApplicationController

  before_action :require_login
  before_action :authorize_global

  # Renders a list of issues assigned to the current user.  Supports
  # filtering by project, tracker and due date.  Issues are sorted so
  # deadlines are shown first, open issues appear before closed ones and
  # tasks with remaining estimate float to the top of the list.  Each
  # row contains input fields for hours, comments and date.
  def index
    @today = User.current.today

    # Build filter lists for the UI.  The list of projects is limited to
    # those where the current user has permission to log time.  Trackers
    # are global as they are the same across projects.
    @projects = allowed_projects
    @trackers = Tracker.order(:position)

    @selected_project_id = params[:project_id].presence
    @selected_tracker_id = params[:tracker_id].presence
    # Capture date range filters instead of a single due date. If present,
    # these will be used to filter issues with due_date on or after the start date
    # and/or on or before the end date.
    @selected_due_date_start = params[:due_date_start].presence
    @selected_due_date_end   = params[:due_date_end].presence

    issues = Issue.includes(:status, :project)
                  .where(:assigned_to_id => User.current.id)

    if @selected_project_id
      issues = issues.where(:project_id => @selected_project_id)
    end
    if @selected_tracker_id
      issues = issues.where(:tracker_id => @selected_tracker_id)
    end
    # Apply due date range filtering. If only the start date is present, return
    # issues with a due date on or after that date. If only the end date is
    # present, return issues with a due date on or before that date. If both
    # are present, return issues with a due date in the specified range.
    if @selected_due_date_start.present?
      begin
        date_start = Date.parse(@selected_due_date_start)
        issues = issues.where('issues.due_date >= ?', date_start)
      rescue ArgumentError
        # Ignore invalid start date
      end
    end
    if @selected_due_date_end.present?
      begin
        date_end = Date.parse(@selected_due_date_end)
        issues = issues.where('issues.due_date <= ?', date_end)
      rescue ArgumentError
        # Ignore invalid end date
      end
    end

    # Sorting criteria:
    #  1. due date ascending (NULLs last)
    #  2. closed status (open issues first)
    #  3. remaining time descending (tasks with work left float up)
    #  4. issue id for deterministic ordering
    issues = issues.order(Arel.sql("CASE WHEN issues.due_date IS NULL THEN 1 ELSE 0 END, issues.due_date ASC"))
    issues = issues.joins(:status).order('issue_statuses.is_closed ASC')

    @issues = issues

    # Compute how many hours the user has already logged today.  This is
    # displayed at the top of the page to provide immediate feedback.
    @hours_today = TimeEntry.where(:user_id => User.current.id, :spent_on => @today).sum(:hours)

    # If the user provided a summary_date parameter, compute the total
    # hours logged on that date.  The date is parsed safely; if
    # invalid or empty no summary is produced.  This allows users to
    # see how many hours they logged on previous days.
    if params[:summary_date].present?
      begin
        @summary_date = Date.parse(params[:summary_date])
        @hours_summary = TimeEntry.where(:user_id => User.current.id, :spent_on => @summary_date).sum(:hours)
      rescue ArgumentError
        @summary_date = nil
      end
    end
  end

  # Creates time entries from the submitted form.  Expects a
  # nested params[:time_entries] where the keys are issue IDs and
  # values include hours, comments and spent_on date.  Only entries
  # with a positive hours value are saved.  After creation a flash
  # message is shown and the user is redirected back to the index.
  def create
    entries = params[:time_entries] || {}
    saved_count = 0
    entries.each do |issue_id, entry|
      next if entry.blank?
      hours = (entry[:hours] || '').to_f
      next if hours <= 0
      begin
        spent_on = entry[:spent_on].present? ? Date.parse(entry[:spent_on]) : User.current.today
      rescue ArgumentError
        spent_on = User.current.today
      end
      comments = entry[:comments].to_s
      issue = Issue.find_by(:id => issue_id)
      next unless issue
      # Ensure the user has permission to log time on this project
      next unless User.current.allowed_to?(:log_time, issue.project)
      time_entry = TimeEntry.new(
        :project => issue.project,
        :issue => issue,
        :user => User.current,
        :hours => hours,
        :comments => comments,
        :spent_on => spent_on,
        :activity => default_activity_for(issue.project)
      )
      if time_entry.save
        saved_count += 1
      end
    end
    if saved_count > 0
      flash[:notice] = l(:notice_successful_update)
    else
      # Use the namespaced key for the plugin to avoid clashing with other plugins
      flash[:warning] = l(:quick_time_entries_text_no_data_added)
    end
    redirect_to :action => 'index',
                :project_id => params[:project_id],
                :tracker_id => params[:tracker_id],
                :due_date_start => params[:due_date_start],
                :due_date_end   => params[:due_date_end]
  end

  private

  # Only allow access to the quick time entry screen to authenticated
  # users.  Additional checks for log_time permission are performed on
  # individual issues in #create.
  def authorize_global
    deny_access unless User.current.logged?
  end

  # Returns a list of projects for which the current user has the
  # :log_time permission.  This is used to populate the project filter
  # dropdown so users do not see irrelevant projects.
  def allowed_projects
    # Collect projects where the user can log time.  Use distinct
    # because a user may have multiple memberships to the same project.
    Project.joins(:enabled_modules)
           .where(:enabled_modules => { :name => 'time_tracking' })
           .select { |project| User.current.allowed_to?(:log_time, project) }
  end

  # Determine a default activity for a given project.  If the project
  # defines custom activities, use the first active one; otherwise
  # fallback to the first global active activity.  If no activities
  # are found, returns nil.  Redmine will prevent saving time
  # entries without an activity so we attempt to pick a sensible
  # default.
  def default_activity_for(project)
    if project && project.respond_to?(:time_entry_activities)
      activity = project.time_entry_activities.active.first
      return activity if activity
    end
    TimeEntryActivity.active.first
  end
end
