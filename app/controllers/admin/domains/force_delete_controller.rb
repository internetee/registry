module Admin
  module Domains
    class ForceDeleteController < BaseController
      def create
        authorize! :manage, domain

        notice = t('.scheduled')

        domain.transaction do
          domain.skip_papertrail = true
          result = domain.schedule_force_delete(type: force_delete_type,
                                                notify_by_email: notify_by_email?)
          notice = result.errors.messages[:domain].first unless result.valid?
        end

        domain.put_data_to_papertrail
        redirect_to edit_admin_domain_url(domain), notice: notice
      end

      def destroy
        domain.skip_papertrail = true
        authorize! :manage, domain
        domain.cancel_force_delete
        domain.put_data_to_papertrail
        redirect_to edit_admin_domain_url(domain), notice: t('.cancelled')
      end

      private

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
