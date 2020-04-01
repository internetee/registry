module Audit
  extend ActiveSupport::Concern

  included do
    attr_accessor :version_loader

    before_create :add_creator
    before_create :add_updator
    before_update :add_updator

    def add_creator
      self.creator_str = ::User.whodunnit || 'console-root'
      true
    end

    def add_updator
      self.updator_str = ::User.whodunnit || 'console-root'
      true
    end

    def creator
      return if creator_str.blank?

      creator = user_from_id_role_username creator_str
      creator.presence || creator_str
    end

    def updator
      return if updator_str.blank?

      updator = user_from_id_role_username updator_str
      updator.presence || updator_str
    end

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

    def objects_for(ids)
      ver_class = "Audit::#{name}".constantize
      return unless ver_class

      calculate_from_versions(ver_class: ver_class, ids: ids)
    end

    def calculate_from_versions(ver_class:, ids:)
      ver_class.where(id: ids.to_a)
          .order(:object_id)
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
