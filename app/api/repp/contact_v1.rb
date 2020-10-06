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
          requires :name, type: String, desc: 'Full name of contact'
          requires :ident, type: String, desc: 'Government identifier of contact'
          requires :ident_type, type: String, desc: 'Type of contact ident'
          requires :ident_country_code, type: String, desc: 'Ident country code'
          requires :country_code, type: String, desc: 'Address country'
          requires :phone, type: String, desc: 'Phone number of contact. In format of +country_prefix.number'
          requires :email, type: String, desc: 'Email address of contact'
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

      post '/' do
        @legal_doc = params[:legal_documents]
        @contact = Contact.new(params[:contact])
        @contact.registrar = current_user.registrar
        action = Actions::ContactCreate.new(@contact, @legal_doc)

        if action.call
          @response = { contact: { id: @contact.code } }
        else
          status :bad_request
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
          optional :phone, type: String, desc: 'Phone number of contact. In format of +country_prefix.number'
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

      post '/:code' do
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
          status :bad_request
          @response = { errors: @contact.errors }
        end
      end
    end
  end
end
