module Admin
  module Domains
    class RegistryLockController < BaseController

      def destroy
        set_domain
        authorize! :manage, @domain
        if @domain.remove_registry_lock
          redirect_to edit_admin_domain_url(@domain), notice: t('admin.domains.registry_lock_delete.success')
        else
          redirect_to edit_admin_domain_url(@domain), alert: t('admin.domains.registry_lock_delete.error')
        end
      end

      private

      def set_domain
        @domain = Domain.find(params[:domain_id])
      end
    end
  end
end
