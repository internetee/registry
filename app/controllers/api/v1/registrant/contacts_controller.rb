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
          serialized_contacts = contacts.collect { |contact| serialize_contact(contact, false) }
          render json: serialized_contacts
        end

        def show
          contact = representable_contact(params[:uuid])
          links = params[:links] == 'true'

          if contact
            render json: serialize_contact(contact, links)
          else
            render json: { errors: [{ base: ['Contact not found'] }] }, status: :not_found
          end
        end

        def do_need_update_contacts
          result = current_registrant_user.do_need_update_contacts?
          render json: { update_contacts: result[:result], counter: result[:counter] }
        end

        def update_contacts
          contacts = current_registrant_user.update_contacts

          render json: { message: 'get it', contacts: contacts }
        end

        def update
          p '------'
          p params
          p '-----'
          contact = find_contact_and_update_credentials(params[:uuid], params[:name], params[:email], params[:phone])

          reparsed_request = reparsed_request(request.body.string)
          disclosed_attributes = reparsed_request[:disclosed_attributes]
          p '--------'

          # render_disclosed_attributes_error and return if disclosed_attributes.present? && contact.org? &&
                                                          # !disclosed_attributes.include?('phone')

          contact.disclosed_attributes = disclosed_attributes if disclosed_attributes
          publishable = reparsed_request[:registrant_publishable]
          contact.registrant_publishable = publishable if publishable.in? [true, false]


          logger.debug "Setting.address_processing is set to #{Setting.address_processing}"
          contact.address = parse_address(params[:address]) if Setting.address_processing && params[:address]
          render_address_error and return if !Setting.address_processing && params[:address]

          contact.fax = params[:fax] if ENV['fax_enabled'] == 'true' && params[:fax].present?

          logger.debug "ENV['fax_enabled'] is set to #{ENV['fax_enabled']}"
          render_fax_error and return if ENV['fax_enabled'] != 'true' && params[:fax]

          contact = update_and_notify!(contact)
          p '--- contact'
          p contact
          p '-------'

          render json: serialize_contact(contact, true)
        end

        private

        def representable_contact(uuid)
          country = current_registrant_user.country.alpha2
          contact = Contact.find_by(uuid: uuid, ident: current_registrant_user.ident,
                                    ident_type: 'priv', ident_country_code: country)
          return contact if contact

          Contact.find_by(uuid: uuid, ident_type: 'org', ident: company_codes,
                          ident_country_code: country)
        rescue CompanyRegister::NotAvailableError
          nil
        end

        def company_codes
          current_registrant_user.companies.collect(&:registration_number)
        end

        def current_user_contacts
          current_registrant_user.contacts(representable: false)
        rescue CompanyRegister::NotAvailableError
          current_registrant_user.direct_contacts
        end

        def serialize_contact(contact, links)
          Serializers::RegistrantApi::Contact.new(contact, links).to_json
        end

        def logger
          Rails.logger
        end

        def render_disclosed_attributes_error
          error_msg = "Legal person's data is visible by default and cannot be concealed." \
                      ' Please remove this parameter.'
          render json: { errors: [{ disclosed_attributes: [error_msg] }] }, status: :bad_request
        end

        def parse_address(address)
          Contact::Address.new(
            address[:street],
            address[:zip],
            address[:city],
            address[:state],
            address[:country_code]
          )
        end

        def render_address_error
          error_msg = 'Address processing is disabled and therefore cannot be updated'
          render json: { errors: [{ address: [error_msg] }] }, status: :bad_request
        end

        def render_fax_error
          error_msg = 'Fax processing is disabled and therefore cannot be updated'
          render json: { errors: [{ address: [error_msg] }] }, status: :bad_request
        end

        def update_and_notify!(contact)
          contact.transaction do
            contact.save!
            action = current_registrant_user.actions.create!(contact: contact, operation: :update)
            contact.registrar.notify(action)
          end

          contact
        end

        def reparsed_request(request_body)
          reparsed_request = ActiveSupport::JSON.decode(request_body).with_indifferent_access
          logger.debug 'Reparsed request is following'
          logger.debug reparsed_request.to_s

          reparsed_request
        end

        def find_contact_and_update_credentials(uuid, name, email, phone)
          contact = current_user_contacts.find_by!(uuid: uuid)
          contact.name = name if name.present?
          contact.email = email if email.present?
          contact.phone = phone if phone.present?

          contact
        end
      end
    end
  end
end
