module Repp
  module V1
    module Domains
      class RenewsController < BaseController
        def bulk_renew
          @epp_errors ||= []

          if bulk_renew_params[:domains].instance_of?(Array)
            domains = bulk_renew_domains
          else
            @epp_errors << { code: 2005, msg: 'Domains attribute must be an array' }
          end

          return handle_errors if @epp_errors.any?

          renew = run_bulk_renew_task(domains, bulk_renew_params[:renew_period])
          return render_success(data: { updated_domains: domains.map(&:name) }) if renew.valid?

          @epp_errors << { code: 2304, msg: renew.errors.full_messages.join(',') }
          handle_errors
        end

        private

        def run_bulk_renew_task(domains, period)
          ::Domains::BulkRenew::Start.run(domains: domains, period_element: period,
                                          registrar: current_user.registrar)
        end

        def bulk_renew_params
          params do
            params.require(%i[domains renew_period])
            params.permit(:domains, :renew_period)
          end
        end

        def bulk_renew_domains
          @epp_errors ||= []
          domains = []
          bulk_renew_params[:domains].each do |idn|
            domain = Epp::Domain.find_by_idn(idn)
            domains << domain if domain
            @epp_errors << { code: 2304, msg: "Object does not exist: #{idn}" } unless domain
          end

          domains
        end
      end
    end
  end
end
