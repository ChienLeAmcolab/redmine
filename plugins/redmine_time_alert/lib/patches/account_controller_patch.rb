module RedmineTimeAlert
  module AccountControllerPatch
    def self.prepended(base)
      base.class_eval do
        before_action :permit_time_alert_attributes, only: [:update]

        private

        def permit_time_alert_attributes
          return unless params[:user]
          params[:user].permit(:time_alert_enabled, :email_alert_enabled)
        end
      end
    end
  end
end
