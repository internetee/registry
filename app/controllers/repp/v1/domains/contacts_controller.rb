module Repp
  module V1
    module Domains
      class ContactsController < BaseController
        before_action :set_current_contact, only: [:update]
        before_action :set_new_contact, only: [:update]

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

        def contact_params
          params.require(%i[current_contact_id new_contact_id])
          params.permit(:current_contact_id, :new_contact_id)
        end
      end
    end
  end
end
