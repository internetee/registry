module Audit
  extend ActiveSupport::Concern

  included do
    attr_accessor :version_loader
    attr_accessor :history_action

    before_create :add_creator
    before_create :add_updator
    before_update :add_updator

    has_many :versions, class_name: "::Audit::#{name}History",
                        foreign_key: 'object_id'

    def add_creator
      self.creator_str = ::User.whodunnit || 'console-root' if respond_to?(:creator_str=)
      true
    end

    def add_updator
      self.updator_str = ::User.whodunnit || 'console-root' if respond_to?(:updator_str=)
      true
    end

    def creator
      return if creator_str.blank?

      user_from_id_role_username(creator_str) || creator_str
    end

    def updator
      return if updator_str.blank?

      user_from_id_role_username(updator_str) || updator_str
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
    def versions_for(ids:)
      ver_class = "Audit::#{name}History".constantize
      return unless ver_class

      calculate_from_versions(ver_class: ver_class, ids: ids, field: :object_id)
    end

    def objects_for(ids:, initial: false)
      ver_class = "Audit::#{name}History".constantize
      return unless ver_class

      result = if initial
                 name.constantize.where(id: ids)
               else
                 calculate_from_versions(ver_class: ver_class, ids: ids, field: :id)
               end
      result
    end

    def calculate_from_versions(ver_class:, ids:, field:)
      ver = ver_class.where(field => ids.to_a)
      ver = order_version(ver)
      ver.where(field => ids.to_a)
         .order(:object_id)
         .order(recorded_at: :desc)
         .map do |version|
           columns = column_names
           object = generate_object_from_version(version: version, columns: columns)
           object.version_loader = version
           object.history_action = version.action
           object
         end
    end

    def generate_object_from_version(version:, columns:)
      case version.action
      when 'DELETE'
        new(version[:old_value].slice(*columns))
      else
        new(version[:new_value].slice(*columns))
      end

    end

    def order_version(ver)
      case name
    when 'Nameserver', 'Dnskey'
      ver.order(action: :desc).order(recorded_at: :desc)
    else
      ver.order(:object_id).order(recorded_at: :desc)
    end
    end
  end
end
