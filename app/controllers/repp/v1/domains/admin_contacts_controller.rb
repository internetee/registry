module Repp
  module V1
    module Domains
      class AdminContactsController < BaseContactsController
        def update
          super

          unless @new_contact.identical_to?(@current_contact)
            @epp_errors.add(:epp_errors,
                            msg: 'New and current admin contacts ident data must be identical',
                            code: '2304')
          end

          return handle_errors if @epp_errors.any?

          affected, skipped = AdminDomainContact.replace(@current_contact, @new_contact)
          @response = { affected_domains: affected, skipped_domains: skipped }
          render_success(data: @response)
        end
      end
    end
  end
end
