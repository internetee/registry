module Api
  module V1
    module BusinessRegistry
      module Concerns
        module TokenAuthentication
          extend ActiveSupport::Concern

          included do
            before_action :find_reserved_domain
          end

          private

          def find_reserved_domain
            token = extract_token_from_header
            @reserved_domain_status = ReservedDomainStatus.find_by(access_token: token)

            if @reserved_domain_status.nil?
              render json: { error: "Invalid token" }, status: :unauthorized
            elsif @reserved_domain_status.token_expired?
              render json: { error: "Token expired. Please refresh the token: PATCH || PUT '/api/v1/business_registry/refresh_token'" }, status: :unauthorized
            else
              @reserved_domain = ReservedDomain.find_by(name: @reserved_domain_status.name)
              render json: { error: "Domain not found in reserved list" }, status: :not_found if @reserved_domain.nil?
            end
          end

          def extract_token_from_header
            request.headers['Authorization']&.split(' ')&.last
          end
        end
      end
    end
  end
end
