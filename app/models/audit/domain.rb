module Audit
  class Domain < Base
    self.table_name = 'audit.domains'

    CHILDREN_VERSIONS_HASH = {
      dnskeys: Audit::Dnskey,
      registrant: Audit::Contact,
      nameservers: Nameserver,
      tech_contacts: Audit::Contact,
      admin_contacts: Audit::Contact
    }.with_indifferent_access.freeze

    ransacker :name do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
                                      Arel::Nodes.build_quoted('name'))
    end

    ransacker :registrant_id do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
                                      Arel::Nodes.build_quoted('registrant_id'))
    end

    ransacker :registrar_id do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
                                      Arel::Nodes.build_quoted('registrar_id'))
    end

    scope 'not_creates', -> { where.not(action: 'CREATE') }

    def uuid
      new_value['uuid']
    end

    # def previous
    #   self.class.where(object_id: object_id).where('id < ?', id).last
    # end

    def prepare_children_history
      children.each_with_object({}) do |(key, value), hash|
        klass = CHILDREN_VERSIONS_HASH[key]
        next unless klass

        result = klass.where(object_id: value).where(recorded_at: date_range)
        hash[key] = result unless result.blank?
      end
    end

    def date_range
      next_version_recorded_at = self.next&.recorded_at || Time.zone.now
      (recorded_at..next_version_recorded_at)
    end
  end
end
