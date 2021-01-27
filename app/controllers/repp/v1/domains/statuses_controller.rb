module Repp
  module V1
    module Domains
      class StatusesController < BaseController
        before_action :set_domain, only: %i[update destroy]
        before_action :verify_status
        before_action :verify_status_removal, only: [:destroy]
        before_action :verify_status_create, only: [:update]

        api :DELETE, '/repp/v1/domains/:domain_name/statuses/:status'
        desc 'Remove status from specific domain'
        param :domain_name, String, required: true, desc: 'Domain name'
        param :status, String, required: true, desc: 'Status to be removed'
        def destroy
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
          @domain.statuses = @domain.statuses << params[:id]
          handle_errors(@domain) and return unless @domain.save

          render_success(data: { domain: @domain.name, status: params[:id] })
        end

        private

        def verify_status
          allowed_statuses = [DomainStatus::CLIENT_HOLD].freeze
          stat = params[:id]

          return if allowed_statuses.include?(stat)

          @domain.add_epp_error('2306', nil, nil, "#{I18n.t(:client_side_status_editing_error)}: status #{stat}")
          handle_errors(@domain)
        end

        def verify_status_removal
          stat = params[:id]
          return if @domain.statuses.include?(stat)

          @domain.add_epp_error('2306', nil, nil, "#{I18n.t(:client_side_status_editing_error)}: status #{stat}")
          handle_errors(@domain)
        end

        def verify_status_create
          stat = params[:id]
          return unless @domain.statuses.include?(stat)

          @domain.add_epp_error('2306', nil, nil, "#{I18n.t(:client_side_status_editing_error)}: status #{stat}")
          handle_errors(@domain)
        end
      end
    end
  end
end
