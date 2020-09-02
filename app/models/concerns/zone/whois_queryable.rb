module Concerns
  module Zone
    module WhoisQueryable
      extend ActiveSupport::Concern

      included do
        after_save :update_whois_record, if: :subzone?
        after_destroy :update_whois_record
      end

      def subzone?
        origin.include? '.'
      end

      def update_whois_record
        UpdateWhoisRecordJob.enqueue origin, 'zone'
      end

      def generate_data
        wr = Whois::Record.find_or_initialize_by(name: origin)
        wr.json = generate_json
        wr.save
      end

      def generate_json
        data = {}.with_indifferent_access
        [domain_vars, registrar_vars, registrant_vars].each do |h|
          data.merge!(h)
        end

        data
      end

      # Take note - since this concern only used to zone whois queries, dnssec keys are set to
      # empty array
      def domain_vars
        { disclaimer: Setting.registry_whois_disclaimer, name: origin,
          registered: created_at.try(:to_s, :iso8601), status: ['ok (paid and in zone)'],
          changed: updated_at.try(:to_s, :iso8601), email: Setting.registry_email,
          admin_contacts: [contact_vars], tech_contacts: [contact_vars],
          nameservers: nameserver_vars, dnssec_keys: [], dnssec_changed: nil }
      end

      def registrar_vars
        { registrar: Setting.registry_juridical_name, registrar_website: Setting.registry_url,
          registrar_phone: Setting.registry_phone }
      end

      def registrant_vars
        { registrant: Setting.registry_juridical_name, registrant_reg_no: Setting.registry_reg_no,
          registrant_ident_country_code: Setting.registry_country_code, registrant_kind: 'org',
          registrant_disclosed_attributes: %w[name email] }
      end

      def contact_vars
        { name: Setting.registry_invoice_contact, email: Setting.registry_email,
          disclosed_attributes: %w[name email] }
      end

      def nameserver_vars
        vars = []
        return vars unless ns_records

        parsed_ns = ns_records.gsub("\r", '').gsub("\n", '')
        parsed_ns.split("#{origin}. IN NS ").each do |ns|
          ns.delete_suffix! '.'
          vars << ns if ns.match? Nameserver::HOSTNAME_REGEXP
        end

        vars
      end
    end
  end
end
