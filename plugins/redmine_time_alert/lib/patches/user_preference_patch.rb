module RedmineTimeAlert
  module UserPreferencePatch
    def self.prepended(base)
      base.class_eval do
        # Declare the attributes that can be set safely
        safe_attributes :time_alert_enabled, :email_alert_enabled

        # Callback to set default values for these attributes when a new record is initialized
        after_initialize :set_default_alert_flags, if: :new_record?

        def set_default_alert_flags
          # If the attribute is nil, assign '1' (equivalent to true)
          self.time_alert_enabled  = '1' if self.time_alert_enabled.nil?
          self.email_alert_enabled = '1' if self.email_alert_enabled.nil?
        end

        # Define getter, setter, and boolean check methods for each attribute
        %w(time_alert_enabled email_alert_enabled).each do |attr|
          # Getter: if nil => true, otherwise compare with '1'
          define_method(attr) do
            value = self[attr.to_sym]
            value.nil? ? true : (value.to_s == '1')
          end

          # Setter: store as '1' or '0'
          define_method("#{attr}=") do |value|
            self[attr.to_sym] = (value.to_s == 'true' || value.to_s == '1') ? '1' : '0'
          end

          # Boolean check method: e.g. user.pref.time_alert_enabled?
          define_method("#{attr}?") do
            send(attr)
          end
        end
      end
    end
  end
end

unless UserPreference.included_modules.include?(RedmineTimeAlert::UserPreferencePatch)
  UserPreference.include(RedmineTimeAlert::UserPreferencePatch)
end
