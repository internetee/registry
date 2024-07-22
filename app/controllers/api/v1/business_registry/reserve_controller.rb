module Api
  module V1
    module BusinessRegistry
      class ReserveController < ::Api::V1::BaseController
        before_action :set_cors_header
        before_action :validate_params
        before_action :authenticate, only: [:create]

        def create
          name = params[:name]&.downcase&.strip
        
          reserved_domain = ReservedDomain.find_or_initialize_by(name: name)
        
          if reserved_domain.persisted?
            reserved_domain.refresh_token if reserved_domain.token_expired?
            render json: { message: "Domain already reserved", token: reserved_domain.access_token }, status: :ok
          elsif reserved_domain.save
            render json: { message: "Domain reserved successfully", token: reserved_domain.access_token }, status: :created
          else
            render json: { error: "Failed to reserve domain", details: reserved_domain.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def set_cors_header
          allowed_origins = ENV['ALLOWED_ORIGINS'].split(',')
          if allowed_origins.include?(request.headers['Origin'])
            response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
          else
            render json: { error: "Unauthorized origin" }, status: :unauthorized
          end
        end

        def validate_params
          if params[:name].blank?
            render json: { error: "Missing required parameter: name" }, status: :bad_request
          end
        end
      end
    end
  end
end
