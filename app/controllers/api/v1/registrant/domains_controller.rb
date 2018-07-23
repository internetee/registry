require 'rails5_api_controller_backport'
require 'auth_token/auth_token_decryptor'

module Api
  module V1
    module Registrant
      class DomainsController < BaseController
        def index
          registrant = ::Registrant.find_by(ident: current_user.registrant_ident)
          unless registrant
            render json: Domain.all
          else
            domains = Domain.where(registrant_id: registrant.id)
            render json: domains
          end
        end
      end
    end
  end
end
