module Repp
  module V1
    module Domains
      class PendingUpdatesController < BaseController
        before_action :set_domain

        THROTTLED_ACTIONS = %i[destroy].freeze
        include Shunter::Integration::Throttle

        api :DELETE, '/repp/v1/domains/:domain_name/pending_update'
        param :domain_name, String, desc: 'Domain name'
        desc 'Cancel a pending registrant change of a specific domain'
        def destroy
          authorize!(:update, @domain)

          result = ::Domains::CancelPendingUpdate.run(domain: @domain,
                                                      initiator: current_user.username)
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
