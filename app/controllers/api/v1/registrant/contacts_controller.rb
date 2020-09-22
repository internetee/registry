require 'serializers/registrant_api/contact'

module Api
  module V1
    module Registrant
      class ContactsController < ::Api::V1::Registrant::BaseController
        def index
          limit = params[:limit] || 200
          offset = params[:offset] || 0

          if limit.to_i > 200 || limit.to_i < 1
            render(json: { errors: [{ limit: ['parameter is out of range'] }] },
                   status: :bad_request) && return
          end

          if offset.to_i.negative?
            render(json: { errors: [{ offset: ['parameter is out of range'] }] },
                   status: :bad_request) && return
          end

          contacts = current_user_contacts.limit(limit).offset(offset)
          serialized_contacts = contacts.collect { |contact| serialize_contact(contact) }
          render json: serialized_contacts
        end

        def show
          contact = current_user_contacts.find_by(uuid: params[:uuid])

          if contact
            render json: serialize_contact(contact)
          else
            render json: { errors: [{ base: ['Contact not found'] }] }, status: :not_found
          end
        end

        def update
          contact = current_user_contacts.find_by!(uuid: params[:uuid])
          contact.name = params[:name] if params[:name].present?
          contact.email = params[:email] if params[:email].present?
          contact.phone = params[:phone] if params[:phone].present?

          # Needed to support passing empty array, which otherwise gets parsed to nil
          # https://github.com/rails/rails/pull/13157
          reparsed_request_json = ActiveSupport::JSON.decode(request.body.string)
                                                     .with_indifferent_access
          disclosed_attributes = reparsed_request_json[:disclosed_attributes]

          if disclosed_attributes
            if contact.org?
              error_msg = "Legal person's data is visible by default and cannot be concealed." \
                          ' Please remove this parameter.'
              render json: { errors: [{ disclosed_attributes: [error_msg] }] }, status: :bad_request
              return
            end

            contact.disclosed_attributes = disclosed_attributes
          end

          if Setting.address_processing && params[:address]
            address = Contact::Address.new(params[:address][:street],
                                           params[:address][:zip],
                                           params[:address][:city],
                                           params[:address][:state],
                                           params[:address][:country_code])
            contact.address = address
          end

          if !Setting.address_processing && params[:address]
            error_msg = 'Address processing is disabled and therefore cannot be updated'
            render json: { errors: [{ address: [error_msg] }] }, status: :bad_request and return
          end

          if ENV['fax_enabled'] == 'true'
            contact.fax = params[:fax] if params[:fax].present?
          end

          if ENV['fax_enabled'] != 'true' && params[:fax]
            error_msg = 'Fax processing is disabled and therefore cannot be updated'
            render json: { errors: [{ address: [error_msg] }] }, status: :bad_request and return
          end

          contact.transaction do
            contact.save!
            action = current_registrant_user.actions.create!(contact: contact, operation: :update)
            contact.registrar.notify(action)
          end

          render json: serialize_contact(contact)
        end

        private

        def current_user_contacts
          current_registrant_user.contacts(representable: false)
        rescue CompanyRegister::NotAvailableError
          current_registrant_user.direct_contacts
        end

        def serialize_contact(contact)
          Serializers::RegistrantApi::Contact.new(contact).to_json
        end
      end
    end
  end
end
