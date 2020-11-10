class Domain
  module ForceDelete
    class NotifyByEmail
      include Interactor

      def call
        return unless notify_by_email?

        if context.type == :fast_track
          send_email
          context.domain.update(contact_notification_sent_date: Time.zone.today)
        else
          context.domain.update(template_name: context.domain.notification_template)
        end
      end

      private

      def notify_by_email?
        ActiveRecord::Type::Boolean.new.cast(params[:notify_by_email])
      end

      def send_email
        DomainDeleteMailer.forced(domain: context.domain,
                                  registrar: context.domain.registrar,
                                  registrant: context.domain.registrant,
                                  template_name: context.domain.notification_template).deliver_now
      end
    end
  end
end
