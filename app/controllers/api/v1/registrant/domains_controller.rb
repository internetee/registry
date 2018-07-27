require 'rails5_api_controller_backport'

module Api
  module V1
    module Registrant
      class DomainsController < ActionController::API

        def show
          @domain = Domain.find_by(uuid: params[:uuid])

          if @domain
            render json: @domain
          else
            render json: { errors: ["Domain not found"] }, status: :not_found
          end
        end
      end
    end
  end
end
