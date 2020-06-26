module Audit
  class DomainHistory < BaseHistory
    self.table_name = 'audit.domains'

    CHILDREN_VERSIONS_HASH = {
      dnskeys: Audit::DnskeyHistory,
      dnskeys_initial: Audit::DnskeyHistory,
      registrant: Audit::ContactHistory,
      nameservers: Audit::NameserverHistory,
      tech_contacts: Audit::ContactHistory,
      tech_contacts_initial: Audit::ContactHistory,
      admin_contacts: Audit::ContactHistory,
      admin_contacts_initial: Audit::ContactHistory,
    }.with_indifferent_access.freeze

    CHILDREN_INITIAL_HASH = {
        dnskeys: Dnskey,
        dnskeys_initial: Dnskey,
        registrant: Contact,
        registrant_initial: Contact,
        nameservers: Nameserver,
        tech_contacts: Contact,
        tech_contacts_initial: Contact,
        admin_contacts: Contact,
        admin_contacts_initial: Contact,
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
                     .merge(new_value['children'] || {}) do |_key, old_val, new_val|
        result = (old_val + new_val).uniq
        result.reject(&:blank?)
      end
      current_hash.merge(object_history_children) do |key, old_val, new_val|
        result = if %w[dnskeys dnskeys_initial nameservers].include? key
                   (old_val + new_val).uniq
                 else
                   old_val
                 end
        result.reject(&:blank?)
      end
    end

    def prepare_children_history
      result = children.each_with_object({}) do |(key, value), hash|
        klass = show_initial?(key) ? CHILDREN_INITIAL_HASH[key] : CHILDREN_VERSIONS_HASH[key]
        next unless klass

        value = prepare_value(key: key, value: value) unless show_initial?(key)
        res = if show_initial?(key)
                calculate_initial(klass: klass, value: value, key: key)
              else
                calculate_history(klass: klass, value: value)
              end
        res = Contact.where(id: transfer_registrant_id) if transfer(key)

        hash[key] = res unless res.blank? || (res.respond_to?(:all?) && res.all?(&:blank?))
      end
      result
    end

    def show_initial?(key)
      initial? && !%w[nameservers dnskeys].include?(key)
    end

    def date_range
      next_version_recorded_at = self.next_version&.recorded_at || Time.zone.now
      (recorded_at...next_version_recorded_at)
    end

    def calculate_history(klass:, value:)
      result = klass.where(object_id: value).where(recorded_at: date_range).order(action: :desc)
      result
    end

    def calculate_initial(klass:, value:, key:)
      result = case key
               when 'registrant', 'tech_contacts', 'admin_contacts'
                 if children["#{key}_initial"]&.is_a?(Hash)
                   klass.new(children["#{key}_initial"])
                 elsif children["#{key}_initial"]&.is_a?(Array)
                  children["#{key}_initial"]&.map { |attrs| klass.new(attrs) }
                 end
               else
                 klass.where(id: value)
               end
      result
    end

    def domain_contact_admin_changes
      DomainContactHistory.by_domain(self.object_id).admin.by_date(date_range)
    end

    def domain_contact_tech_changes
      DomainContactHistory.by_domain(self.object_id).tech.by_date(date_range)
    end

    def transfer(key)
      transfer? && key == 'registrant' && !initial?
    end

    def transfer?
      diff['registrant_id'].present?
    end

    def renew?
      diff['valid_to'].present?
    end

    def transfer_registrant_id
      diff['registrant_id']
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
