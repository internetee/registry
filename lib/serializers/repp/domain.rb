module Serializers
  module Repp
    class Domain
      attr_reader :domain

      def initialize(domain, sponsored: true, simplify: false)
        @domain = domain
        @sponsored = sponsored
        @simplify = simplify
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def to_json(obj = domain)
        return simple_object if @simplify

        json = {
          name: obj.name, registrant: registrant,
          created_at: obj.created_at, updated_at: obj.updated_at,
          expire_time: obj.expire_time, outzone_at: obj.outzone_at,
          delete_date: obj.delete_date, force_delete_date: obj.force_delete_date,
          contacts: contacts, nameservers: nameservers, dnssec_keys: dnssec_keys,
          statuses: statuses, registrar: registrar, status_notes: obj.status_notes,
          dispute: Dispute.active.exists?(domain_name: obj.name)
        }
        json[:transfer_code] = obj.auth_info if @sponsored

        json
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def contacts
        domain.domain_contacts.includes(:contact).map do |dc|
          contact = dc.contact
          { code: contact.code, type: dc.type,
            name: contact.name_disclosed_by_registrar(domain.registrar_id) }
        end
      end

      def nameservers
        domain.nameservers.order(:created_at).as_json(only: %i[id hostname ipv4 ipv6])
      end

      def dnssec_keys
        domain.dnskeys.order(:updated_at).as_json(only: %i[id flags protocol alg public_key])
      end

      def registrar
        domain.registrar.as_json(only: %i[name website])
      end

      def registrant
        rant = domain.registrant
        {
          name: rant.name,
          code: rant.code,
        }
      end

      def statuses(statuses_with_notes = {})
        status_notes = domain.status_notes
        domain.statuses.each do |status|
          status_note = status_notes[status.to_s].presence || ''
          statuses_with_notes.merge!({ "#{status}": status_note })
        end
        statuses_with_notes.with_indifferent_access
      end

      private

      def simple_object
        json = {
          name: domain.name,
          expire_time: domain.expire_time,
          registrant: registrant,
          statuses: statuses,
        }
        json[:transfer_code] = domain.auth_info if @sponsored
        json
      end
    end
  end
end
