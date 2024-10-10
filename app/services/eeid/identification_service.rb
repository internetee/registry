# frozen_string_literal: true

module Eeid
  # This class handles identification services.
  class IdentificationService < Base
    CLIENT_ID = ENV['ident_service_client_id']
    CLIENT_SECRET = ENV['ident_service_client_secret']

    def initialize
      super(CLIENT_ID, CLIENT_SECRET)
    end

    def create_identification_request(request_params)
      request_endpoint('/api/ident/v1/identification_requests', method: :post, body: request_params)
    end

    def get_identification_request(id)
      request_endpoint("/api/ident/v1/identification_requests/#{id}")
    end
  end
end
