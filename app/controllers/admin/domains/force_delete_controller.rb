module Admin
  module Domains
    class ForceDeleteController < BaseController
      def create
        authorize! :manage, domain

        notice = t('.scheduled')

        domain.transaction do
          result = domain.schedule_force_delete(type: force_delete_type,
                                                notify_by_email: notify_by_email?)
          notice = result.errors.messages[:domain].first unless result.valid?
        end

        redirect_to edit_admin_domain_url(domain), notice: notice
      end

      def destroy
        authorize! :manage, domain
        deceased_registrant = domain.registrant if domain.template_name == 'deceased_person'
        domain.cancel_force_delete
        clear_death_date(deceased_registrant) if deceased_registrant
        redirect_to edit_admin_domain_url(domain), notice: t('.cancelled')
      end

      private

      # Without this the death registry check would start the force delete
      # again the next day. The contact is checked again in a year.
      def clear_death_date(contact)
        contact.death_date = nil
        contact.death_registry_checked_at = Time.zone.now
        contact.save!(validate: false)
      end

      def domain
        @domain ||= Domain.find(params[:domain_id])
      end

      def notify_by_email?
        ActiveRecord::Type::Boolean.new.cast(params[:notify_by_email])
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
