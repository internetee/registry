module Admin
  module Domains
    class ForceDeleteController < BaseController
      def create
        authorize! :manage, domain

        domain.transaction do
          domain.schedule_force_delete(type: force_delete_type)
          domain.registrar.notifications.create!(text: t('force_delete_set_on_domain',
                                                         domain_name: domain.name))

          notify_by_email if notify_by_email?
        end

        redirect_to edit_admin_domain_url(domain), notice: t('.scheduled')
      end

      def notify_by_email
        if force_delete_type == :fast_track
          send_email
          domain.update(contact_notification_sent_date: Time.zone.today)
        else
          domain.update(template_name: params[:template_name])
        end
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
        ActiveRecord::Type::Boolean.new.cast(params[:notify_by_email])
      end

      def send_email
        DomainDeleteMailer.forced(domain: domain,
                                  registrar: domain.registrar,
                                  registrant: domain.registrant,
                                  template_name: params[:template_name]).deliver_now
      end

      def force_delete_type
        soft_delete? ? :soft : :fast_track
      end

      def soft_delete?
        ActiveRecord::Type::Boolean.new.cast(params[:soft_delete])
      end
    end
  end
end
