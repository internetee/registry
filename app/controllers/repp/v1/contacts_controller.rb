module Repp
  module V1
    class ContactsController < BaseController
      before_action :find_contact, only: %i[show update]

      ## GET /repp/v1/contacts
      def index
        record_count = current_user.registrar.contacts.count
        contacts = showable_contacts(params[:details], params[:limit] || 200,
                                     params[:offset] || 0)

        render(json: { contacts: contacts, total_number_of_records: record_count }, status: :ok)
      end

      ## GET /repp/v1/contacts/1
      def show
        render_success(data: @contact.as_json)
      end

      ## GET /repp/v1/contacts/check/1
      def check
        contact = Epp::Contact.find_by(code: params[:id])
        data = { contact: { id: params[:id], available: contact.nil? } }

        render_success(data: data)
      end

      ## POST /repp/v1/contacts
      def create
        @contact = Epp::Contact.new(contact_params_with_address, current_user.registrar, epp: false)
        action = Actions::ContactCreate.new(@contact, params[:legal_documents],
                                            contact_ident_params)

        unless action.call
          handle_errors(@contact)
          return
        end

        render_success(create_update_success_data)
      end

      ## PUT /repp/v1/contacts/1
      def update
        action = Actions::ContactUpdate.new(@contact, contact_params_with_address,
                                            params[:legal_document],
                                            contact_ident_params(required: false), current_user)

        unless action.call
          handle_errors(@contact)
          return
        end

        render_success(create_update_success_data)
      end

      def contact_addr_present?
        return false unless contact_addr_params.key?(:addr)

        contact_addr_params[:addr].keys.any?
      end

      def create_update_success_body
        { code: opt_addr? ? 1100 : nil, data: { contact: { id: @contact.code } },
          message: opt_addr? ? I18n.t('epp.contacts.completed_without_address') : nil }
      end

      def showable_contacts(details, limit, offset)
        contacts = current_user.registrar.contacts.limit(limit).offset(offset)
        unless Contact.address_processing? && params[:details] == 'true'
          contacts = contacts.select(Contact.attribute_names - Contact.address_attribute_names)
        end

        contacts = contacts.pluck(:code) unless details

        contacts
      end

      def opt_addr?
        !Contact.address_processing? && contact_addr_present?
      end

      def find_contact
        code = params[:id]
        @contact = Epp::Contact.find_by!(code: code)
      end

      def contact_params_with_address
        return contact_create_params unless contact_addr_params.key?(:addr)

        addr = {}
        contact_addr_params[:addr].each_key { |k| addr[k] = contact_addr_params[:addr][k] }
        contact_create_params.merge(addr)
      end

      def contact_create_params
        params.require(:contact).require(%i[name email phone])
        params.require(:contact).permit(:name, :email, :phone)
      end

      def contact_ident_params(required: true)
        if required
          params.require(:contact).require(:ident).require(%i[ident ident_type ident_country_code])
          params.require(:contact).require(:ident).permit(:ident, :ident_type, :ident_country_code)
        else
          params.permit(ident: %i[ident ident_type ident_country_code])
        end
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
