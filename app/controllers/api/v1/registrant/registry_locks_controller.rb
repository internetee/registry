module Api
  module V1
    module Registrant
      class RegistryLocksController < BaseController
        before_action :set_domain
        before_action :authorized_to_manage_locks?

        def create
          if @domain.apply_registry_lock
            render json: @domain
          else
            render json: { errors: [{ base: ['Domain cannot be locked'] }] },
                   status: :unprocessable_entity
          end
        end

        def destroy
          if @domain.remove_registry_lock
            render json: @domain
          else
            render json: { errors: [{ base: ['Domain is not locked'] }] },
                   status: :unprocessable_entity
          end
        end

        private

        def set_domain
          domain_pool = current_user.domains
          @domain = domain_pool.find_by(uuid: params[:domain_uuid])

          return if @domain
          render json: { errors: [{ base: ['Domain not found'] }] },
                 status: :not_found and return
        end

        def authorized_to_manage_locks?
          return if current_user.administered_domains.include?(@domain)

          render json: { errors: [
            { base: ['Only administrative contacts can manage registry locks'] }
          ] },
                 status: :unauthorized and return
        end
      end
    end
  end
end
