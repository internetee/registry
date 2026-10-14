module Serializers
  module Rdap
    # Secrets-free serializer for the internal RDAP domain endpoint
    # (GET /api/v1/internal/rdap/domains/:name).
    #
    # This serializer MUST NEVER emit transfer_code / auth_info /
    # registrant_verification_token. It returns the full normalized row plus the
    # raw disclosure flags (the union of disclosed_attributes and
    # system_disclosed_attributes) — RDAP, not the registry, applies the
    # disclosure policy. Do NOT reuse Serializers::Repp::Domain here: that one
    # emits transfer_code when sponsored.
    class Domain
      attr_reader :domain

      def initialize(domain)
        @domain = domain
      end

      def as_json(*)
        {
          name: domain.name,
          statuses: Array(domain.statuses),
          created_at: iso8601(domain.created_at),
          updated_at: iso8601(domain.updated_at),
          valid_to: iso8601(domain.valid_to),
          outzone_at: iso8601(domain.outzone_at),
          delete_date: iso8601(effective_delete_date),
          registrant: contact(domain.registrant),
          admin_contacts: domain.admin_contacts.map { |c| contact(c) },
          tech_contacts: domain.tech_contacts.map { |c| contact(c) },
          registrar: registrar(domain.registrar),
          nameservers: domain.nameservers.map { |ns| nameserver(ns) },
          dnskeys: domain.dnskeys.map { |dk| dnskey(dk) },
        }
      end

      private

      # Effective delete date as WHOIS uses it: the earliest of delete_date and
      # force_delete_date.
      def effective_delete_date
        [domain.delete_date, domain.force_delete_date].compact.min
      end

      def contact(contact)
        return nil if contact.nil?

        {
          name: contact.name,
          org_name: contact.org_name,
          email: contact.email,
          phone: contact.phone,
          street: contact.street,
          city: contact.city,
          zip: contact.zip,
          country_code: contact.country_code,
          ident: contact.ident,
          ident_type: contact.ident_type,
          ident_country_code: contact.ident_country_code,
          disclosed_attributes: disclosed_attributes(contact),
          registrant_publishable: contact.registrant_publishable,
          updated_at: iso8601(contact.updated_at),
        }
      end

      # Union of the registrant-set and system-set disclosure arrays, in one
      # field (the effective public-disclosure set). RDAP applies policy.
      def disclosed_attributes(contact)
        (Array(contact.disclosed_attributes) +
         Array(contact.system_disclosed_attributes)).uniq
      end

      def registrar(registrar)
        return nil if registrar.nil?

        {
          code: registrar.code,
          name: registrar.name,
          email: registrar.email,
          phone: registrar.phone,
          website: registrar.website,
          reg_no: registrar.reg_no,
        }
      end

      def nameserver(nameserver)
        {
          hostname: nameserver.hostname,
          hostname_puny: nameserver.hostname_puny,
          ipv4: Array(nameserver.ipv4),
          ipv6: Array(nameserver.ipv6),
        }
      end

      def dnskey(dnskey)
        {
          flags: dnskey.flags,
          protocol: dnskey.protocol,
          alg: dnskey.alg,
          public_key: dnskey.public_key,
          ds_key_tag: dnskey.ds_key_tag,
          ds_alg: dnskey.ds_alg,
          ds_digest_type: dnskey.ds_digest_type,
          ds_digest: dnskey.ds_digest,
        }
      end

      def iso8601(value)
        return nil if value.nil?

        value.to_time.utc.iso8601
      end
    end
  end
end
