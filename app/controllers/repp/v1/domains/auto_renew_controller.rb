require 'serializers/repp/domain'

module Repp
  module V1
    module Domains
      class AutoRenewController < BaseController
        before_action :set_domain

        THROTTLED_ACTIONS = %i[show update].freeze
        include Shunter::Integration::Throttle

        api :GET, '/repp/v1/domains/:domain_id/auto_renew'
        desc 'Get automatic renewal preference and current cycle'
        param :domain_id, String, required: true, desc: 'Domain name'
        def show
          authorize!(:update, @domain)
          serializer = Serializers::Repp::Domain.new(@domain)
          render_success(data: { domain: @domain.name, auto_renew: serializer.auto_renew,
                                 rgp_statuses: @domain.rgp_statuses })
        end

        api :PUT, '/repp/v1/domains/:domain_id/auto_renew'
        desc 'Change automatic renewal preference or reverse and refund a cycle'
        param :domain_id, String, required: true, desc: 'Domain name'
        param :auto_renew, Hash, required: true, desc: 'Supply enabled, cycle_id, or both' do
          param :enabled, [true, false, 'true', 'false'], required: false,
                                                       desc: 'Automatic renewal preference'
          param :cycle_id, String, required: false, desc: 'Cycle UUID to reverse and refund'
        end
        def update
          authorize!(:update, @domain)
          attributes = params.require(:auto_renew).permit(:enabled, :cycle_id)
          return handle_errors(@domain) unless valid_attributes?(attributes)

          outcome = Domain.transaction do
            @domain.reload(lock: true)
            ::Domains::AutoRenew::ChangePreference.run(
              domain: @domain, registrar: current_user.registrar,
              enabled: attributes.key?(:enabled) ? [true, 'true'].include?(attributes[:enabled]) : nil,
              reverse_cycle_id: attributes[:cycle_id]
            )
          end
          return handle_errors(@domain) unless outcome.valid?

          serializer = Serializers::Repp::Domain.new(@domain)
          render_success(data: { domain: @domain.name, auto_renew: serializer.auto_renew,
                                 reversal: serializer.reversal(outcome.result) })
        end

        private

        def valid_attributes?(attributes)
          if params[:auto_renew].key?(:enabled) &&
             ![true, false, 'true', 'false'].include?(params[:auto_renew][:enabled])
            @domain.add_epp_error('2005', nil, nil, I18n.t('repp.errors.invalid_auto_renew_boolean'))
          elsif !attributes.key?(:enabled) && attributes[:cycle_id].blank?
            @domain.add_epp_error('2003', nil, nil, I18n.t('repp.errors.auto_renew_parameter_missing'))
          end
          @domain.errors.empty?
        end
      end
    end
  end
end
