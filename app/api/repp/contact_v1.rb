module Repp
  class ContactV1 < Grape::API
    version 'v1', using: :path

    resource :contacts do
      desc 'Return list of contact'
      params do
        optional :limit, type: Integer, values: (1..200).to_a, desc: 'How many contacts to show'
        optional :offset, type: Integer, desc: 'Contact number to start at'
        optional :details, type: String, values: %w(true false), desc: 'Whether to include details'
      end

      get '/' do
        limit = params[:limit] || 200
        offset = params[:offset] || 0

        if params[:details] == 'true'
          contacts = current_user.registrar.contacts.limit(limit).offset(offset)

          unless Contact.address_processing?
            attributes = Contact.attribute_names - Contact.address_attribute_names
            contacts = contacts.select(attributes)
          end
        else
          contacts = current_user.registrar.contacts.limit(limit).offset(offset).pluck(:code)
        end

        @response = {
          contacts: contacts,
          total_number_of_records: current_user.registrar.contacts.count
        }
      end

      desc 'Creates a new contact object'
      params do
        requires :contact, type: Hash, allow_blank: false do
          # Contact info
          requires :name, type: String, desc: 'Full name of contact'
          requires :phone, type: String,
                           desc: 'Phone number of contact. In format of +country_prefix.number'
          requires :email, type: String, desc: 'Email address of contact'
          optional :fax, type: String, allow_blank: true, desc: 'Fax number of contact'

          # Ident
          requires :ident, type: Hash do
            requires :ident, type: String, allow_blank: false,
                             desc: 'Government identifier of contact'
            requires :ident_type, type: String, allow_blank: false, desc: 'Type of contact ident'
            requires :ident_country_code, type: String, allow_blank: false,
                                          desc: 'Ident country code'
          end

          # Physical address
          optional :addr, type: Hash do
            requires :country_code, type: String, allow_blank: false, desc: 'Address country'
            requires :street, type: String, allow_blank: false, desc: 'Address street'
            requires :city, type: String, allow_blank: false, desc: 'Address city'
            requires :zip, type: String, allow_blank: false, desc: 'Address ZIP'
          end
        end

        # Legal document
        optional :legal_document, type: Hash, allow_blank: false do
          requires :body, type: String, desc: 'Raw data of legal document'
          requires :type, type: String, desc: 'Format of legal document'
        end
      end

      post '/' do
        @legal_doc = params[:legal_documents]
        @contact_params = params[:contact]

        # Ident object
        @ident = @contact_params[:ident]
        @contact_params.delete(:ident)

        # Address
        address_present = params[:contact][:addr].keys.any?

        %w[city street zip country_code].each { |k| @contact_params[k] = @contact_params[:addr][k] }
        @contact_params.delete(:addr)

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

          @response = { code: @response_code,
                        description: @response_description,
                        data: { contact: { id: @contact.code } } }
        else
          status(:bad_request)
          @response = { errors: @contact.errors }
        end
      end

      desc 'Update contact properties'
      params do
        requires :contact, type: Hash, allow_blank: false do
          optional :ident, type: Hash, allow_blank: false do
            requires :ident, type: String, desc: 'Government identifier of contact'
            requires :ident_type, type: String, desc: 'Type of contact ident'
            requires :ident_country_code, type: String, desc: 'Ident country code'
          end
          optional :name, type: String, desc: 'Full name of contact'
          optional :country_code, type: String, desc: 'Address country'
          optional :phone, type: String,
                           desc: 'Phone number of contact. In format of +country_prefix.number'
          optional :email, type: String, desc: 'Email address of contact'
          optional :fax, type: String, desc: 'Fax number of contact'
          optional :street, type: String, desc: 'Address street'
          optional :city, type: String, desc: 'Address city'
          optional :zip, type: String, desc: 'Address ZIP'
        end
        optional :legal_document, type: Hash, allow_blank: false do
          requires :body, type: String, desc: 'Raw data of legal document'
          requires :type, type: String, desc: 'Format of legal document'
        end
      end

      put '/:code' do
        @contact = current_user.registrar.contacts.find_by(code: params[:code])
        (status(:not_found) && return) unless @contact

        @new_params = params[:contact]
        @legal_doc = params[:legal_document]
        @ident = params[:contact][:ident] || {}

        action = Actions::ContactUpdate.new(@contact, @new_params,
                                            @legal_doc, @ident, current_user)

        if action.call
          @response = {}
        else
          status(:bad_request)
          @response = { errors: @contact.errors }
        end
      end
    end
  end
end
