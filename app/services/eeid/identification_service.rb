# frozen_string_literal: true

module Eeid
  # This class handles identification services.
  class IdentificationService < Base
    def initialize(ident_type = 'priv')
      super(
        ENV["#{ident_type}_ident_service_client_id"],
        ENV["#{ident_type}_ident_service_client_secret"]
      )
    end

    def create_identification_request(request_params)
      request_endpoint('/api/ident/v1/identification_requests', method: :post, body: request_params)
    end

    def get_identification_request(id)
      request_endpoint("/api/ident/v1/identification_requests/#{id}")
    end

    def get_proof_of_identity(id)
      request_endpoint("/api/ident/v1/identification_requests/#{id}/proof_of_identity")
    end
  end
end
