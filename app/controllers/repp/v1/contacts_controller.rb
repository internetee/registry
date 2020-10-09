module Repp
  module V1
    class ContactsController < BaseController
      before_action :find_contact, only: %i[show update]

      ## GET /repp/v1/contacts
      def index
        limit = params[:limit] || 200
        offset = params[:offset] || 0

        record_count = current_user.registrar.contacts.count
        contacts = current_user.registrar.contacts.limit(limit).offset(offset)

        unless Contact.address_processing? && params[:details] == 'true'
          contacts = contacts.select(Contact.attribute_names - Contact.address_attribute_names)
        end

        contacts = contacts.pluck(:code) unless params[:details]
        resp = { contacts: contacts, total_number_of_records: record_count }
        render(json: resp, status: :ok)
      end

      ## GET /repp/v1/contacts/1
      def show
        render(json: @contact.as_json, status: :ok)
      end

      ## GET /repp/v1/contacts/check/1
      def check
        contact = Epp::Contact.find_by(code: params[:id])

        render json: {
          code: 1000, message: I18n.t('epp.contacts.completed'),
          data: { contact: {
            id: params[:id],
            available: contact.nil?
          } }
        }, status: :ok
      end

      ## POST /repp/v1/contacts
      def create
        @legal_doc = params[:legal_documents]
        @contact_params = contact_create_params
        @ident = contact_ident_params
        address_present = contact_addr_params.keys.any?
        %w[city street zip country_code].each { |k| @contact_params[k] = contact_addr_params[k] }

        @contact = Epp::Contact.new(@contact_params, current_user.registrar, epp: false)

        action = Actions::ContactCreate.new(@contact, @legal_doc, @ident)

        if action.call
          if !Contact.address_processing? && address_present
            @response_code = 1100
            @response_description = I18n.t('epp.contacts.completed_without_address')
          else
            @response_code = 1000
            @response_description = I18n.t('epp.contacts.completed')
          end

          render(json: { code: @response_code,
                         message: @response_description,
                         data: { contact: { id: @contact.code } } },
                         status: :created)
        else
          handle_errors(@contact)
        end
      end

      ## PUT /repp/v1/contacts/1
      def update
        @update = contact_create_params
        %w[city street zip country_code].each { |k| @new_params[k] = contact_addr_params[k] }

        @legal_doc = params[:legal_document]
        @ident = contact_ident_params || {}
        address_present = contact_addr_params.keys.any?
        action = Actions::ContactUpdate.new(@contact, @update, @legal_doc, @ident, current_user)

        if action.call
          if !Contact.address_processing? && address_present
            @response_code = 1100
            @response_description = I18n.t('epp.contacts.completed_without_address')
          else
            @response_code = 1000
            @response_description = I18n.t('epp.contacts.completed')
          end

          render(json: { code: @response_code,
                         message: @response_description,
                         data: { contact: { id: @contact.code } } },
                         status: :ok)
        else
          handle_errors(@contact)
        end
      end

      def find_contact
        code = params[:id]
        @contact = Epp::Contact.find_by!(code: code)
      end

      def contact_create_params
        params.require(:contact).require(%i[name email phone])
        params.require(:contact).permit(:name, :email, :phone)
      end

      def contact_ident_params
        params.require(:contact).require(:ident).require(%i[ident ident_type ident_country_code])
        params.require(:contact).require(:ident).permit(:ident, :ident_type, :ident_country_code)
      end

      def contact_addr_params
        if Contact.address_processing?
          params.require(:contact).require(:addr).require(%i[country_code city street zip])
          params.require(:contact).require(:addr).permit(:country_code, :city, :street, :zip)
        else
          params.require(:contact).permit(addr: %i[country_code city street zip])
        end
      end

      def legal_document_params
        params.require(:legal_document).require(%i[body type])
        params.require(:legal_document).permit(:body, :type)
      end
    end
  end
end
