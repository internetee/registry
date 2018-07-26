require 'rails5_api_controller_backport'

module Api
  module V1
    module Registrant
      class DomainsController < ActionController::API
        def index
          render json: { success: true }
        end

        def show
          render json: { success: true }
        end
      end
    end
  end
end
