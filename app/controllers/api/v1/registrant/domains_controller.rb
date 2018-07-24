require 'rails5_api_controller_backport'
require 'auth_token/auth_token_decryptor'

module API
  module V1
    module Registrant
      class DomainsController < BaseController
        def index
          registrant = ::Registrant.find_by(ident: current_user.registrant_ident)
          if registrant
            domains = Domain.where(registrant_id: registrant.id)
            render json: domains
          else
            render json: []
          end
        end
      end
    end
  end
end
