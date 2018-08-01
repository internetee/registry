require 'rails5_api_controller_backport'
require 'auth_token/auth_token_decryptor'

module Api
  module V1
    module Registrant
      class ContactsController < BaseController
        before_action :set_contacts_pool

        def index
          limit = params[:limit] || 200
          offset = params[:offset] || 0

          if limit.to_i > 200 || limit.to_i < 1
            render(json: { errors: [{ limit: ['parameter is out of range'] }] },
                   status: :bad_request) && return
          end

          if offset.to_i.negative?
            render(json: { errors: [{ offset: ['parameter is out of range'] }] },
                   status: :bad_request) && return
          end

          @contacts = @contacts_pool.limit(limit).offset(offset)
          render json: @contacts
        end

        def show
          @contact = @contacts_pool.find_by(uuid: params[:uuid])

          if @contact
            render json: @contact
          else
            render json: { errors: ['Contact not found'] }, status: :not_found
          end
        end

        private

        def set_contacts_pool
          country_code, ident = current_user.registrant_ident.to_s.split '-'
          @contacts_pool = Contact.where(country_code: country_code, ident: ident)
        end
      end
    end
  end
end
