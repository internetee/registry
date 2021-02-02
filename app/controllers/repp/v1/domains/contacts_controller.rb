module Repp
  module V1
    module Domains
      class ContactsController < BaseController
        before_action :set_current_contact, only: [:update]
        before_action :set_new_contact, only: [:update]
        before_action :set_domain, only: %i[index create destroy]

        def_param_group :contacts_apidoc do
          param :contacts, Array, required: true, desc: 'Array of new linked contacts' do
            param :code, String, required: true, desc: 'Contact code'
            param :type, String, required: true, desc: 'Role of contact (admin/tech)'
          end
        end

        api :GET, '/repp/v1/domains/:domain_name/contacts'
        desc "View domain's admin and tech contacts"
        def index
          admin_contacts = @domain.admin_domain_contacts.pluck(:contact_code_cache)
          tech_contacts = @domain.tech_domain_contacts.pluck(:contact_code_cache)

          data = { admin_contacts: admin_contacts, tech_contacts: tech_contacts }
          render_success(data: data)
        end

        api :POST, '/repp/v1/domains/:domain_name/contacts'
        desc 'Link new contact(s) to domain'
        param_group :contacts_apidoc
        def create
          cta('add')
        end

        api :DELETE, '/repp/v1/domains/:domain_name/contacts'
        desc 'Remove contact(s) from domain'
        param_group :contacts_apidoc
        def destroy
          cta('rem')
        end

        def cta(action = 'add')
          params[:contacts].each { |c| c[:action] = action }
          action = Actions::DomainUpdate.new(@domain, contact_create_params, false)

          # rubocop:disable Style/AndOr
          handle_errors(@domain) and return unless action.call
          # rubocop:enable Style/AndOr

          render_success(data: { domain: { name: @domain.name } })
        end

        def set_current_contact
          @current_contact = current_user.registrar.contacts.find_by!(
            code: contact_params[:current_contact_id]
          )
        end

        def set_new_contact
          @new_contact = current_user.registrar.contacts.find_by!(code: params[:new_contact_id])
        end

        def update
          @epp_errors ||= []
          @epp_errors << { code: 2304, msg: 'New contact must be valid' } if @new_contact.invalid?

          if @new_contact == @current_contact
            @epp_errors << { code: 2304, msg: 'New contact must be different from current' }
          end

          return handle_errors if @epp_errors.any?

          affected, skipped = TechDomainContact.replace(@current_contact, @new_contact)
          @response = { affected_domains: affected, skipped_domains: skipped }
          render_success(data: @response)
        end

        private

        def contact_create_params
          params.permit(:domain_id, contacts: [%i[action code type]])
        end

        def contact_params
          params.require(%i[current_contact_id new_contact_id])
          params.permit(:current_contact_id, :new_contact_id)
        end
      end
    end
  end
end
