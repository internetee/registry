module Api
  module V1
    module BusinessRegistry
      module Concerns
        module CorsHeaders
          extend ActiveSupport::Concern

          included do
            before_action :set_cors_header
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
        end
      end
    end
  end
end
