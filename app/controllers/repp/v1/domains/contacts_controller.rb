module Repp
  module V1
    module Domains
      class ContactsController < BaseContactsController
        before_action :set_domain, only: %i[index create destroy]

        THROTTLED_ACTIONS = %i[index create destroy update].freeze
        include Shunter::Integration::Throttle

        def_param_group :contacts_apidoc do
          param :contacts, Array, required: true, desc: 'Array of new linked contacts' do
            param :code, String, required: true, desc: 'Contact code'
            param :type, String, required: true, desc: 'Role of contact (admin/tech)'
          end
        end

        api :GET, '/repp/v1/domains/:domain_name/contacts'
        desc "View domain's admin and tech contacts"
        def index
          admin_contacts = @domain.admin_domain_contacts.map(&:contact).pluck(:code)
          tech_contacts = @domain.tech_domain_contacts.map(&:contact).pluck(:code)

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

        def update
          super

          if @new_contact == @current_contact
            @epp_errors.add(:epp_errors,
                            msg: 'New contact must be different from current',
                            code: '2304')
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
      end
    end
  end
end
