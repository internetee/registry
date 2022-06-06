module Serializers
  module Repp
    class Contact
      attr_reader :contact

      def initialize(contact, options = {})
        @contact = contact
        @show_address = options[:show_address]
        @domain_params = options[:domain_params] || nil
        @simplify = options[:simplify] || false
      end

      def to_json(obj = contact)
        return simple_object if @simplify

        json = { id: obj.uuid, code: obj.code, name: obj.name, ident: ident,
                 email: obj.email, phone: obj.phone, created_at: obj.created_at,
                 auth_info: obj.auth_info, statuses: statuses,
                 disclosed_attributes: obj.disclosed_attributes, registrar: registrar }
        json[:address] = address if @show_address
        if @domain_params
          json[:domains] = domains
          json[:domains_count] = obj.qualified_domain_ids(@domain_params[:domain_filter]).size
        end
        json
      end

      def registrar
        contact.registrar.as_json(only: %i[name website])
      end

      def ident
        {
          code: contact.ident,
          type: contact.ident_type,
          country_code: contact.ident_country_code,
        }
      end

      def address
        { street: contact.street, zip: contact.zip, city: contact.city,
          state: contact.state, country_code: contact.country_code }
      end

      def domains
        contact.all_domains(page: @domain_params[:page],
                            per: @domain_params[:per_page],
                            params: @domain_params)
               .map do |d|
                 { id: d.uuid, name: d.name, registrar: { name: d.registrar.name },
                   valid_to: d.valid_to, roles: d.roles }
               end
      end

      def statuses
        statuses_with_notes = contact.status_notes
        contact.statuses.each do |status|
          statuses_with_notes.merge!({ "#{status}": '' }) unless statuses_with_notes.key?(status)
        end
        statuses_with_notes
      end

      private

      def simple_object
        {
          id: contact.uuid,
          code: contact.code,
          name: contact.name,
        }
      end
    end
  end
end
