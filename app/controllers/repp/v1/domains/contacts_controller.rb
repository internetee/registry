module Repp
  module V1
    module Domains
      class ContactsController < BaseContactsController
        def update
          super

          if @new_contact == @current_contact
            @epp_errors << { code: 2304, msg: 'New contact must be different from current' }
          end

          return handle_errors if @epp_errors.any?

          affected, skipped = TechDomainContact.replace(@current_contact, @new_contact)
          @response = { affected_domains: affected, skipped_domains: skipped }
          render_success(data: @response)
        end
      end
    end
  end
end
