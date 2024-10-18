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
            allowed_origins = ENV['ALLOWED_ORIGINS'].to_s.split(',')
            origin = request.headers['Origin']

            puts '---- origins ---'
            puts allowed_origins
            puts origin
            puts allowed_origins.include?(origin)
            Rails.logger.info("allowed_origins: #{allowed_origins}")
            Rails.logger.info("origin: #{origin}")
            Rails.logger.info("allowed_origins.include?(origin): #{allowed_origins.include?(origin)}")
            puts '---- origins ---'

            if allowed_origins.include?(origin)
              response.headers['Access-Control-Allow-Origin'] = origin
              response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
              response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, X-Requested-With'
              response.headers['Access-Control-Allow-Credentials'] = 'true'
            end

            if request.method == 'OPTIONS'
              head :no_content
            end
          end
        end
      end
    end
  end
end
