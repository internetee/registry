module Admin
  module Domains
    class ForceDeleteController < BaseController
      def create
        authorize! :manage, domain

        domain.transaction do
          domain.schedule_force_delete
          domain.registrar.notifications.create!(body: t('force_delete_set_on_domain',
                                                         domain_name: domain.name))

          if notify_by_email?
            DomainDeleteMailer.forced(domain: domain,
                                      registrar: domain.registrar,
                                      registrant: domain.registrant,
                                      template_name: params[:template_name]).deliver_now
          end
        end

        redirect_to edit_admin_domain_url(domain), notice: t('.scheduled')
      end

      def destroy
        authorize! :manage, domain
        domain.cancel_force_delete
        redirect_to edit_admin_domain_url(domain), notice: t('.cancelled')
      end

      private

      def domain
        @domain ||= Domain.find(params[:domain_id])
      end

      def notify_by_email?
        ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:notify_by_email])
      end
    end
  end
end
