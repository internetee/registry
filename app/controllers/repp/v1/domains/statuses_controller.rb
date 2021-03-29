module Repp
  module V1
    module Domains
      class StatusesController < BaseController
        before_action :set_domain, only: %i[update destroy]
        before_action :verify_status

        api :DELETE, '/repp/v1/domains/:domain_name/statuses/:status'
        param :domain_name, String, desc: 'Domain name'
        param :status, String, desc: 'Status to be removed'
        desc 'Remove status from specific domain'
        def destroy
          return editing_failed unless domain_with_status?(params[:id])

          @domain.statuses = @domain.statuses.delete(params[:id])
          if @domain.save
            render_success
          else
            handle_errors(@domain)
          end
        end

        api :PUT, '/repp/v1/domains/:domain_name/statuses/:status'
        param :domain_name, String, desc: 'Domain name'
        param :status, String, desc: 'Status to be added'
        desc 'Add status to specific domain'
        def update
          return editing_failed if domain_with_status?(params[:id])

          @domain.statuses << params[:id]
          if @domain.save
            render_success(data: { domain: @domain.name, status: params[:id] })
          else
            handle_errors(@domain)
          end
        end

        private

        def domain_with_status?(status)
          @domain.statuses.include?(status)
        end

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
