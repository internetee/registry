module Audit
  class DomainHistory < BaseHistory
    self.table_name = 'audit.domains'

    CHILDREN_VERSIONS_HASH = {
      dnskeys: Audit::DnskeyHistory,
      registrant: Audit::ContactHistory,
      nameservers: Audit::NameserverHistory,
      tech_contacts: Audit::ContactHistory,
      admin_contacts: Audit::ContactHistory
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

    def object_current_children
      {
        'admin_contacts' => object.admin_contact_ids,
        'tech_contacts' => object.tech_contact_ids,
        'nameservers' => object.nameserver_ids,
        'dnskeys' => object.dnskey_ids,
        'legal_documents' => object.legal_document_ids,
        'registrant' => [object.registrant_id],
      }
    end

    def object_history_children
      {
        'admin_contacts' => Audit::DomainContactHistory.by_domain(object.id).admin.contact_ids,
        'tech_contacts' => Audit::DomainContactHistory.by_domain(object.id).tech.contact_ids,
        'nameservers' => Audit::NameserverHistory.by_domain(object.id).pluck(:object_id),
        'dnskeys' => Audit::DnskeyHistory.by_domain(object.id).pluck(:object_id),
        'registrant' => object_history_registrars
      }
    end

    def object_history_registrars
      self.class.where(object_id: object.id)
          .pluck(Arel.sql("new_value->'registrant_id'"),
                       Arel.sql("old_value->'registrant_id'"))
          .flatten
          .reject(&:blank?)
          .uniq
    end

    def children
      current_hash = (old_value['children'] || {})
                     .merge(new_value['children']) do |_key, old_val, new_val|
        result = (old_val + new_val).uniq
        result.reject(&:blank?)
      end
      current_hash.merge(object_history_children) do |_key, old_val, new_val|
        result = (old_val + new_val).uniq
        result.reject(&:blank?)
      end
    end

    def prepare_children_history
      children.each_with_object({}) do |(key, value), hash|
        klass = CHILDREN_VERSIONS_HASH[key]
        next unless klass

        value = prepare_value(key: key, value: value)
        result = calculate_result(klass: klass,
                                  value: value)

        hash[key] = result unless result.all?(&:blank?)
      end
    end

    def date_range
      next_version_recorded_at = self.next_version&.recorded_at || Time.zone.now
      (recorded_at...next_version_recorded_at)
    end

    def calculate_result(klass:, value:)
      result = klass.where(object_id: value).where(recorded_at: date_range)
      result
    end

    def prepare_value(key:, value:)
      return value unless value.all?(&:blank?)
      case key
      when 'dnskeys'
        self.object.dnskey_ids
      when 'registrant'
        [self.object.registrant_id]
      when 'nameservers'
        self.object.nameserver_ids
      when 'tech_contacts'
        self.object.tech_contact_ids
      when 'admin_contacts'
        self.object.admin_contact_ids
      else # 'legal_documents'
        [self.object.legal_document_id]
      end
    end
  end
end
