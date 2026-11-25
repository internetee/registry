# Papertrail concerns is mainly tested at country spec
module Versions
  extend ActiveSupport::Concern

  # ReservedDomain meta uses lambdas: a symbol naming a changed attribute
  # resolves to its previous value on update.
  META = {
    'Domain' => { children: :children_log },
    'Contact' => { children: :children_log },
    'ReservedDomain' => {
      source: ->(record) { record.audit_source },
      reason: ->(record) { record.audit_reason },
      reason_note: ->(record) { record.audit_reason_note },
      domain_name: ->(record) { record.name },
      registrar_id: ->(record) { record.audit_registrar_id }
    }
  }.freeze

  included do
    attr_accessor :version_loader

    options = { versions: { class_name: "Version::#{model_name}Version" } }
    options[:meta] = META[model_name.name] if META.key?(model_name.name)
    has_paper_trail options

    # add creator and updator
    before_create :add_creator
    before_create :add_updator
    before_update :add_updator

    def add_creator
      self.creator_str = ::PaperTrail.request.whodunnit
      true
    end

    def add_updator
      self.updator_str = ::PaperTrail.request.whodunnit
      true
    end

    def creator
      return nil if creator_str.blank?

      creator = user_from_id_role_username creator_str
      creator.present? ? creator : creator_str
    end

    def updator
      return nil if updator_str.blank?

      updator = user_from_id_role_username updator_str
      updator.present? ? updator : updator_str
    end

    def user_from_id_role_username(str)
      registrar = Registrar.find_by(name: str)
      user = registrar.api_users.first if registrar

      str_match = str.match(/^(\d+)-(ApiUser:|api-|AdminUser:|RegistrantUser:)/)
      user ||= User.find_by(id: str_match[1]) if str_match

      user
    end

    # callbacks
    def touch_domain_version
      domain.try(:touch)
    end

    def touch_domains_version
      domains.each(&:touch)
    end
  end

  module ClassMethods
    def all_versions_for(ids, time)
      ver_klass = paper_trail.version_class
      from_history = ver_klass.where(item_id: ids.to_a)
                              .order(:item_id)
                              .preceding(time + 1, true)
                              .select("distinct on (item_id) #{ver_klass.table_name}.*")
                              .map do |ver|
                                valid_columns = ver.item_type.constantize&.column_names
                                o = new(ver.object&.slice(*valid_columns))
                                o.version_loader = ver
                                changes = ver.object_changes.to_h&.slice(*valid_columns)
                                changes.each { |k, v| o.public_send("#{k}=", v[-1]) }
                                o
                              end
      not_in_history = where(id: (ids.to_a - from_history.map(&:id)))

      from_history + not_in_history
    end
  end
end
