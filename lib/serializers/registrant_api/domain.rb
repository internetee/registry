module Serializers
  module RegistrantApi
    class Domain
      attr_reader :domain

      def initialize(domain)
        @domain = domain
      end

      def to_json(_opts)
        {
          id: domain.uuid,
          name: domain.name,
          registrar: {
            name: domain.registrar.name,
            website: domain.registrar.website,
          },
          registered_at: domain.registered_at,
          valid_to: domain.valid_to,
          created_at: domain.created_at,
          updated_at: domain.updated_at,
          registrant: {
            name: domain.registrant.name,
            id: domain.registrant.uuid,
          },
          tech_contacts: contacts(:tech),
          admin_contacts: contacts(:admin),
          transfer_code: domain.transfer_code,
          name_dirty: domain.name_dirty,
          name_puny: domain.name_puny,
          period: domain.period,
          period_unit: domain.period_unit,
          creator_str: domain.creator_str,
          updator_str: domain.updator_str,
          legacy_id: domain.legacy_id,
          legacy_registrar_id: domain.legacy_registrar_id,
          legacy_registrant_id: domain.legacy_registrant_id,
          outzone_at: domain.outzone_at,
          delete_date: domain.delete_date,
          registrant_verification_asked_at: domain.registrant_verification_asked_at,
          registrant_verification_token: domain.registrant_verification_token,
          pending_json: domain.pending_json,
          force_delete_date: domain.force_delete_date,
          statuses: domain.statuses,
          locked_by_registrant_at: domain.locked_by_registrant_at,
          status_notes: domain.status_notes,
          nameservers: nameservers,
        }
      end

      private

      def contacts(type)
        contact_pool = begin
                         if type == :tech
                           domain.tech_contacts
                         elsif type == :admin
                           domain.admin_contacts
                         end
                       end

        array_of_contacts = []
        contact_pool.map do |contact|
          array_of_contacts.push(name: contact.name, id: contact.uuid)
        end

        array_of_contacts
      end

      def nameservers
        array_of_nameservers = []

        domain.nameservers.map do |nameserver|
          array_of_nameservers.push(hostname: nameserver.hostname, ipv4: nameserver.ipv4,
                                    ipv6: nameserver.ipv6)
        end

        array_of_nameservers
      end
    end
  end
end
