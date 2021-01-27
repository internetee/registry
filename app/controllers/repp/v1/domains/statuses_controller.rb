module Repp
  module V1
    module Domains
      class StatusesController < BaseController
        before_action :set_domain, only: %i[update destroy]
        before_action :verify_status

        api :DELETE, '/repp/v1/domains/:domain_name/statuses/:status'
        desc 'Remove status from specific domain'
        param :domain_name, String, required: true, desc: 'Domain name'
        param :status, String, required: true, desc: 'Status to be removed'
        def destroy
          return editing_failed unless @domain.statuses.include?(params[:id])

          @domain.statuses = @domain.statuses.delete(params[:id])
          if @domain.save
            render_success
          else
            handle_errors(@domain)
          end
        end

        api :PUT, '/repp/v1/domains/:domain_name/statuses/:status'
        desc 'Add status to specific domain'
        param :domain_name, String, required: true, desc: 'Domain name'
        param :status, String, required: true, desc: 'Status to be added'
        def update
          return editing_failed if @domain.statuses.include?(params[:id])

          @domain.statuses = @domain.statuses << params[:id]
          # rubocop:disable Style/AndOr
          handle_errors(@domain) and return unless @domain.save
          # rubocop:enable Style/AndOr

          render_success(data: { domain: @domain.name, status: params[:id] })
        end

        private

        def verify_status
          allowed_statuses = [DomainStatus::CLIENT_HOLD].freeze
          stat = params[:id]

          return if allowed_statuses.include?(stat)

          @domain.add_epp_error('2306', nil, nil,
                                "#{I18n.t(:client_side_status_editing_error)}: status #{stat}")
          handle_errors(@domain)
        end

        def editing_failed
          stat = params[:id]

          @domain.add_epp_error('2306', nil, nil,
                                "#{I18n.t(:client_side_status_editing_error)}: status #{stat}")
          handle_errors(@domain)
        end
      end
    end
  end
end
