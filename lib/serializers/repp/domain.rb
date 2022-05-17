module Serializers
  module Repp
    class Domain
      attr_reader :domain

      def initialize(domain, sponsored: true)
        @domain = domain
        @sponsored = sponsored
      end

      # rubocop:disable Metrics/AbcSize
      def to_json(obj = domain)
        json = {
          name: obj.name, registrant: obj.registrant.code, created_at: obj.created_at,
          updated_at: obj.updated_at, expire_time: obj.expire_time, outzone_at: obj.outzone_at,
          delete_date: obj.delete_date, force_delete_date: obj.force_delete_date,
          contacts: contacts, nameservers: nameservers, dnssec_keys: dnssec_keys,
          statuses: obj.status_notes, registrar: registrar
        }
        json[:transfer_code] = obj.auth_info if @sponsored
        json
      end
      # rubocop:enable Metrics/AbcSize

      def contacts
        domain.domain_contacts.map { |c| { code: c.contact.code, type: c.type } }
      end

      def nameservers
        domain.nameservers.map { |ns| { hostname: ns.hostname, ipv4: ns.ipv4, ipv6: ns.ipv6 } }
      end

      def dnssec_keys
        domain.dnskeys.map do |nssec|
          { flags: nssec.flags, protocol: nssec.protocol, alg: nssec.alg,
            public_key: nssec.public_key }
        end
      end

      def registrar
        { name: domain.registrar.name, website: domain.registrar.website }
      end
    end
  end
end
