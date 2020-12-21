module Repp
  module V1
    module Domains
      class RenewsController < BaseController
        before_action :validate_renew_period, only: [:bulk_renew]
        before_action :select_renewable_domains, only: [:bulk_renew]

        def bulk_renew
          renew = run_bulk_renew_task(@domains, bulk_renew_params[:renew_period])
          return render_success(data: { updated_domains: @domains.map(&:name) }) if renew.valid?

          @epp_errors << { code: 2002,
                           msg: renew.errors.keys.map { |k, _v| renew.errors[k] }.join(', ') }
          handle_errors
        end

        private

        def validate_renew_period
          @epp_errors ||= []
          periods = Depp::Domain::PERIODS.map { |p| p[1] }
          return if periods.include? bulk_renew_params[:renew_period]

          @epp_errors << { code: 2005, msg: 'Invalid renew period' }
        end

        def select_renewable_domains
          @epp_errors ||= []

          if bulk_renew_params[:domains].instance_of?(Array)
            @domains = bulk_renew_domains
          else
            @epp_errors << { code: 2005, msg: 'Domains attribute must be an array' }
          end

          return handle_errors if @epp_errors.any?
        end

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
            domain = Epp::Domain.find_by(name: idn)
            domains << domain if domain
            @epp_errors << { code: 2304, msg: "Object does not exist: #{idn}" } unless domain
          end

          domains
        end
      end
    end
  end
end
