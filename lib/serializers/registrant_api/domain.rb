module Serializers
  module RegistrantApi
    class Domain
      attr_reader :domain

      def initialize(domain)
        @domain = domain
      end

      def to_json
        {
          id: @domain.uuid,
          name: @domain.name,
          registrar: {
            name: @domain.registrar.name,
            website: @domain.registrar.website,
          },
          registered_at: @domain.registered_at,
          valid_to: @domain.valid_to,
          created_at: @domain.created_at,
          updated_at: @domain.updated_at,
          registrant: @domain.registrant_name,
          transfer_code: @domain.transfer_code,
          name_dirty: @domain.name_dirty,
          name_puny: @domain.name_puny,
          period: @domain.period,
          period_unit: @domain.period_unit,
          creator_str: @domain.creator_str,
          updator_str: @domain.updator_str,
          legacy_id: @domain.legacy_id,
          legacy_registrar_id: @domain.legacy_registrar_id,
          legacy_registrant_id: @domain.legacy_registrant_id,
          outzone_at: @domain.outzone_at,
          delete_at: @domain.delete_at,
          registrant_verification_asked_at: @domain.registrant_verification_asked_at,
          registrant_verification_token: @domain.registrant_verification_token,
          pending_json: @domain.pending_json,
          force_delete_at: @domain.force_delete_at,
          statuses: @domain.statuses,
          locked_by_registrant_at: @domain.locked_by_registrant_at,
          reserved: @domain.reserved,
          status_notes: @domain.status_notes,
          nameservers: nameservers,
        }
      end

      private

      def nameservers
        array_of_nameservers = Array.new

        @domain.nameservers.map do |nameserver|
          array_of_nameservers << { hostname: nameserver.hostname, ipv4: nameserver.ipv4,
                                   ipv6: nameserver.ipv6 }
        end

        array_of_nameservers
      end
    end
  end
end
