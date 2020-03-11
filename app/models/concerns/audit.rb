module Audit
  extend ActiveSupport::Concern

  included do
    attr_accessor :version_loader
  end

  module ClassMethods
    def audit_versions_for(ids, time)

      ver_class = "Audit::#{self.name}".constantize
      return unless ver_class

      from_history = ver_class.where(object_id: ids.to_a).
        order(:object_id).
        where('recorded_at < ?', time + 1).
        order(recorded_at: :desc).
        map do |version|
          valid_columns = self.column_names
          object = self.new(version[:new_value].slice(*valid_columns))
          object.version_loader = version
          object
        end
      from_history
    end
  end
end
