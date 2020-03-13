module Audit
  extend ActiveSupport::Concern
  include AuditBase

  included do
    attr_accessor :version_loader

    def user_from_id_role_username(str)
      registrar = Registrar.find_by(name: str)
      user = registrar.api_users.first if registrar

      str_match = str.match(/^(\d+)-(ApiUser:|api-|AdminUser:|RegistrantUser:)/)
      user ||= User.find_by(id: str_match[1]) if str_match

      user
    end
  end

  module ClassMethods
    def audit_versions_for(ids, time)
      ver_class = "Audit::#{name}".constantize
      return unless ver_class

      calculate_from_history(ver_class, ids, time)
    end

    def calculate_from_history(ver_class, ids, time)
      ver_class.where(object_id: ids.to_a)
               .order(:object_id)
               .where('recorded_at < ?', time + 1)
               .order(recorded_at: :desc)
               .map do |version|
                 valid_columns = column_names
                 object = new(version[:new_value].slice(*valid_columns))
                 object.version_loader = version
                 object
               end
    end
  end
end
