module Api
  module V1
    module Whois
      class ContactRequestsController < BaseController
        before_action :authenticate_shared_key

        # POST api/v1/contact_requests/
        def create
          return head(:bad_request) if contact_request_params[:email].blank?

          ::Whois::ContactRequest.record(contact_request_params)
          head(:created)
        rescue ActionController::ParameterMissing
          head(:bad_request)
        end

        def update; end

        def contact_request_params
          params.require(:contact_request).permit(:email, :whois_record_id, :name, :status, :id)
        end
      end
    end
  end
end
