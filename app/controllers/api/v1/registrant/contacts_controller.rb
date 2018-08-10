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
            render json: { errors: [{ base: ['Contact not found'] }] }, status: :not_found
          end
        end

        private

        def set_contacts_pool
          country_code, ident = current_user.registrant_ident.to_s.split '-'
          associated_domain_ids = begin
            BusinessRegistryCache.fetch_by_ident_and_cc(ident, country_code).associated_domain_ids
          end

          available_contacts_ids = begin
            DomainContact.where(domain_id: associated_domain_ids).pluck(:contact_id) |
              Domain.where(id: associated_domain_ids).pluck(:registrant_id)
          end

          @contacts_pool = Contact.where(id: available_contacts_ids)
        rescue Soap::Arireg::NotAvailableError => error
          Rails.logger.fatal("[EXCEPTION] #{error}")
          render json: { errors: [{ base: ['Business Registry not available'] }] },
                 status: :service_unavailable and return
        end
      end
    end
  end
end
