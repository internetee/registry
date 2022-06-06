module Repp
  module V1
    module Domains
      class RenewsController < BaseController
        before_action :validate_renew_period, only: [:bulk_renew]
        before_action :select_renewable_domains, only: [:bulk_renew]
        before_action :set_domain, only: [:create]

        api :POST, 'repp/v1/domains/:domain_name/renew'
        desc 'Renew domain'
        param :renews, Hash, required: true, desc: 'Renew parameters' do
          param :period, Integer, required: true, desc: 'Renew period. Month (m) or year (y)'
          param :period_unit, String, required: true, desc: 'For how many months or years to renew'
          param :exp_date, String, required: true, desc: 'Current expiry date for domain'
        end
        def create
          authorize!(:renew, @domain)
          action = Actions::DomainRenew.new(@domain, renew_params[:renews], current_user.registrar)

          unless action.call
            handle_errors(@domain)
            return
          end

          render_success(data: { domain: { name: @domain.name, id: @domain.uuid } })
        end

        def bulk_renew
          authorize! :manage, :repp
          renew = run_bulk_renew_task(@domains, bulk_renew_params[:renew_period])
          return render_success(data: { updated_domains: @domains.map(&:name) }) if renew.valid?

          msg = renew.errors.attribute_names.map { |k, _v| renew.errors[k] }.join(', ')
          @epp_errors.add(:epp_errors, msg: msg, code: '2002')
          handle_errors
        end

        private

        def renew_params
          params.permit(:domain_id, renews: %i[period period_unit exp_date])
        end

        def validate_renew_period
          @epp_errors ||= ActiveModel::Errors.new(self)
          periods = Depp::Domain::PERIODS.map { |p| p[1] }
          return if periods.include? bulk_renew_params[:renew_period]

          @epp_errors.add(:epp_errors, msg: 'Invalid renew period', code: '2005')
        end

        def select_renewable_domains
          @epp_errors ||= ActiveModel::Errors.new(self)

          if bulk_renew_params[:domains].instance_of?(Array)
            @domains = bulk_renew_domains
            @epp_errors.add(:epp_errors, msg: 'Domains cannot be empty', code: '2005') if @domains.empty?
          else
            @epp_errors.add(:epp_errors, msg: 'Domains attribute must be an array', code: '2005')
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
          @epp_errors ||= ActiveModel::Errors.new(self)
          domains = []
          bulk_renew_params[:domains].each do |idn|
            domain = Epp::Domain.find_by(name: idn)
            domains << domain if domain
            next if domain

            @epp_errors.add(:epp_errors,
                            msg: "Object does not exist: #{idn}",
                            code: '2304')
          end

          domains
        end
      end
    end
  end
end
