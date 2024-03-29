module Repp
  module V1
    module Domains
      class TransfersController < BaseController
        before_action :set_domain, only: [:create]

        THROTTLED_ACTIONS = %i[create].freeze
        include Shunter::Integration::Throttle

        api :POST, 'repp/v1/domains/:domain_name/transfer'
        desc 'Transfer a specific domain'
        param :transfer, Hash, required: true, desc: 'Renew parameters' do
          param :transfer_code, String, required: true, desc: 'Renew period. Month (m) or year (y)'
        end
        def create
          action = Actions::DomainTransfer.new(@domain, transfer_params[:transfer][:transfer_code],
                                               current_user.registrar)

          unless action.call
            handle_errors(@domain)
            return
          end

          render_success(data: { domain: { name: @domain.name, type: 'domain_transfer' } })
        end

        private

        def set_domain
          domain_id = transfer_params[:domain_id]
          h = {}
          h[domain_id.match?(/\A[0-9]+\z/) ? :id : :name] = domain_id
          @domain = Epp::Domain.find_by!(h)
        end

        def transfer_params
          params.permit(:domain_id, transfer: [:transfer_code])
        end
      end
    end
  end
end
