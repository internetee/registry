module Repp
  module V1
    module Domains
      class PendingNotificationsController < BaseController
        before_action :set_domain

        THROTTLED_ACTIONS = %i[create].freeze
        include Shunter::Integration::Throttle

        api :POST, '/repp/v1/domains/:domain_name/pending_notification'
        param :domain_name, String, desc: 'Domain name'
        desc 'Resend the registrant confirmation email of a pending registrant change or delete'
        def create
          authorize!(:update, @domain)

          result = ::Domains::ResendPendingNotification.run(domain: @domain)
          unless result.valid?
            @domain.add_epp_error('2304', 'status', DomainStatus::PENDING_UPDATE,
                                  result.errors.full_messages.join(', '))
            return handle_errors(@domain)
          end

          render_success(data: { domain: { name: @domain.name } })
        end
      end
    end
  end
end
