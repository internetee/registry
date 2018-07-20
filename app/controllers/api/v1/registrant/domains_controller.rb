require 'rails5_api_controller_backport'
require 'auth_token/auth_token_decryptor'

module Api
  module V1
    module Registrant
      class DomainsController < ActionController::API
        before_filter :authenticate

        def index
          registrant = ::Registrant.find_by(ident: current_user.registrant_ident)
          unless registrant
            render json: Domain.all
          else
            domains = Domain.where(registrant_id: registrant.id)
            render json: domains
          end
        end

        private

        def bearer_token
          pattern = /^Bearer /
          header  = request.headers['Authorization']
          header.gsub(pattern, '') if header && header.match(pattern)
        end

        def authenticate
          decryptor = AuthTokenDecryptor.create_with_defaults(bearer_token)
          decryptor.decrypt_token

          if decryptor.valid?
            sign_in decryptor.user
          else
            render json: { error: "Not authorized" }, status: 403
          end
        end
      end
    end
  end
end
