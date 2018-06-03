module Repp
  class DomainContactsV1 < Grape::API
    version 'v1', using: :path

    resource :domains do
      resource :contacts do
        patch '/' do
          current_contact = current_user.registrar.contacts
                                .find_by(code: params[:current_contact_id])
          new_contact = current_user.registrar.contacts.find_by(code: params[:new_contact_id])

          unless current_contact
            error!({ error: { type: 'invalid_request_error',
                              param: 'current_contact_id',
                              message: "No such contact: #{params[:current_contact_id]}"} },
                   :bad_request)
          end

          unless new_contact
            error!({ error: { type: 'invalid_request_error',
                              param: 'new_contact_id',
                              message: "No such contact: #{params[:new_contact_id]}" } },
                   :bad_request)
          end

          if current_contact == new_contact
            error!({ error: { type: 'invalid_request_error',
                              message: 'New contact ID must be different from current' \
                                ' contact ID' } },
                   :bad_request)
          end

          affected_domains, skipped_domains = TechDomainContact
                                                  .replace(current_contact, new_contact)
          @response = { affected_domains: affected_domains, skipped_domains: skipped_domains }
        end
      end
    end
  end
end
