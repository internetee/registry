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
        deceased_contacts = deceased_contacts_of_force_delete
        domain.cancel_force_delete
        # Otherwise the death registry check would start it again the next day
        deceased_contacts.each(&:clear_death_date!)
        redirect_to edit_admin_domain_url(domain), notice: t('.cancelled')
      end

      private

      def deceased_contacts_of_force_delete
        case domain.template_name
        when 'deceased_person' then [domain.registrant]
        when 'deceased_admin_contact' then domain.admin_contacts.select(&:death_date)
        else []
        end
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
