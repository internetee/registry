module Admin
  module Domains
    class ForceDeleteController < BaseController
      # The reason picks the email template; without it the template was
      # guessed from the domain data, e.g. "the registrant has died" for any
      # private registrant. "other" sends no email, as there is no letter for it.
      REASONS = %w[private_person legal_person invalid_email invalid_phone other].freeze

      def create
        authorize! :manage, domain
        return redirect_to edit_admin_domain_url(domain), alert: t('.reason_missing') unless reason_valid?
        # CheckForceDeleteLift would lift it the next day
        return redirect_to edit_admin_domain_url(domain), alert: t('.no_invalid_emails') if no_invalid_emails?

        notice = t('.scheduled')

        domain.transaction do
          result = domain.schedule_force_delete(type: force_delete_type,
                                                notify_by_email: notify_by_email?,
                                                reason: template_reason,
                                                email: invalid_emails)
          notice = result.errors.messages[:domain].first unless result.valid?
        end

        redirect_to edit_admin_domain_url(domain), notice: notice
      end

      def destroy
        authorize! :manage, domain
        deceased_contacts = deceased_contacts_of_force_delete
        if domain.template_name == 'deceased_person'
          # Restores the force delete it replaced, if any
          DeathRegistry::ForceDeletePriority.new(domain).stop
        else
          domain.cancel_force_delete
        end
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

      def reason_valid?
        REASONS.include?(params[:reason])
      end

      def template_reason
        params[:reason] unless params[:reason] == 'other'
      end

      def no_invalid_emails?
        params[:reason] == 'invalid_email' && invalid_emails.blank?
      end

      # Shown in the force delete status note and the registrar's poll message
      def invalid_emails
        domain.contact_emails_verification_failed.join(', ').presence if params[:reason] == 'invalid_email'
      end

      def notify_by_email?
        template_reason.present? && ActiveRecord::Type::Boolean.new.cast(params[:notify_by_email])
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
