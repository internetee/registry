class Domain
  module ForceDeleteInteractor
    class NotifyByEmail
      include Interactor

      def call
        return unless context.notify_by_email

        if context.type == :fast_track
          send_email
          domain.update(contact_notification_sent_date: Time.zone.today)
        else
          domain.update(template_name: context.domain.notification_template)
        end
      end

      private

      def domain
        @domain ||= context.domain
      end

      def send_email
        DomainDeleteMailer.forced(domain: domain,
                                  registrar: domain.registrar,
                                  registrant: domain.registrant,
                                  template_name: domain.notification_template).deliver_now
      end
    end
  end
end
