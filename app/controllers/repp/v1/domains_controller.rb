module Repp
  module V1
    class DomainsController < BaseController
      before_action :set_authorized_domain, only: [:transfer_info]

      def index
        records = current_user.registrar.domains
        domains = records.limit(limit).offset(offset)
        domains = domains.pluck(:name) unless params[:details] == 'true'

        render_success(data: { domains: domains, total_number_of_records: records.count })
      end

      def transfer_info
        contact_fields = %i[code name ident ident_type ident_country_code phone email street city
                            zip country_code statuses]

        data = {
          domain: @domain.name,
          registrant: @domain.registrant.as_json(only: contact_fields),
          admin_contacts: @domain.admin_contacts.map { |c| c.as_json(only: contact_fields) },
          tech_contacts: @domain.tech_contacts.map { |c| c.as_json(only: contact_fields) },
        }

        render_success(data: data)
      end

      def transfer
        @errors ||= []
        @successful = []

        params[:data][:domain_transfers].each do |transfer|
          initiate_transfer(transfer)
        end

        if @errors.any?
          render_success(data: { errors: @errors })
        else
          render_success(data: successful)
        end
      end

      def initiate_transfer(transfer)
        domain = transferable_domain(transfer[:domain_name], transfer[:transfer_code])
        return unless domain

        DomainTransfer.request(domain, current_user.registrar)
        @successful << { type: 'domain_transfer', attributes: { domain_name: domain.name } }
      end

      def transferable_domain(domain_name, transfer_code)
        domain = Domain.find_by(name: domain_name)
        # rubocop:disable Style/AndOr
        add_error("#{domain_name} does not exist") and return unless domain
        valid_transfer_code = domain.transfer_code.eql?(transfer_code)
        add_error("#{domain_name} transfer code is wrong") and return unless valid_transfer_code
        # rubocop:enable Style/AndOr

        domain
      end

      def add_error(msg)
        @errors ||= []
        @errors << { title: msg }
      end

      private

      def transfer_params
        params.require(:data).require(:domain_transfers).each do |t|
          t.require(:domain_name)
          t.permit(:domain_name)
          t.require(:transfer_code)
          t.permit(:transfer_code)
        end
        params.require(:data).permit(domain_transfers: %i[domain_name transfer_code])
      end

      def transfer_info_params
        params.require(:id)
        params.permit(:id)
      end

      def set_authorized_domain
        @epp_errors ||= []
        h = {}
        h[transfer_info_params[:id].match?(/\A[0-9]+\z/) ? :id : :name] = transfer_info_params[:id]
        @domain = Domain.find_by!(h)

        return if @domain.transfer_code.eql?(request.headers['Auth-Code'])

        @epp_errors << { code: '401', msg: I18n.t('errors.messages.epp_authorization_error') }
        handle_errors
      end

      def limit
        params[:limit] || 200
      end

      def offset
        params[:offset] || 0
      end

      def index_params
        params.permit(:limit, :offset, :details)
      end
    end
  end
end
