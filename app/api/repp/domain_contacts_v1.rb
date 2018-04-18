module Repp
  class DomainContactsV1 < Grape::API
    version 'v1', using: :path

    resource :domains do
      resource :contacts do
        patch '/' do
          predecessor = current_user.registrar.contacts.find_by(code: params[:predecessor])
          successor = current_user.registrar.contacts.find_by(code: params[:successor])

          unless predecessor
            error!({ error: { type: 'invalid_request_error',
                              param: 'predecessor',
                              message: "No such contact: #{params[:predecessor]}" } }, :bad_request)
          end

          unless successor
            error!({ error: { type: 'invalid_request_error',
                              param: 'successor',
                              message: "No such contact: #{params[:successor]}" } }, :bad_request)
          end

          if predecessor == successor
            error!({ error: { type: 'invalid_request_error',
                              message: 'New contact ID must be different from current' \
                                ' contact ID' } },
                   :bad_request)
          end

          affected_domains, skipped_domains = TechDomainContact.replace(predecessor, successor)
          @response = { affected_domains: affected_domains, skipped_domains: skipped_domains }
        end
      end
    end
  end
end
