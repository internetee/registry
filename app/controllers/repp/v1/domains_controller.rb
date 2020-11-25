require 'serializers/registrant_api/domain'
module Repp
  module V1
    class DomainsController < BaseController
      before_action :set_authorized_domain, only: %i[transfer_info]
      before_action :set_domain, only: %i[show]

      def index
        records = current_user.registrar.domains
        domains = records.limit(limit).offset(offset)
        domains = domains.pluck(:name) unless index_params[:details] == 'true'

        render_success(data: { domains: domains, total_number_of_records: records.count })
      end

      def show
        render_success(data: { domain: Serializers::RegistrantApi::Domain.new(@domain).to_json })
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

        transfer_params[:domain_transfers].each do |transfer|
          initiate_transfer(transfer)
        end

        render_success(data: { success: @successful, failed: @errors })
      end

      def initiate_transfer(transfer)
        domain = Epp::Domain.find_or_initialize_by(name: transfer[:domain_name])
        action = Actions::DomainTransfer.new(domain, transfer[:transfer_code],
                                             current_user.registrar)

        if action.call
          @successful << { type: 'domain_transfer', domain_name: domain.name }
        else
          @errors << { type: 'domain_transfer', domain_name: domain.name,
                       errors: domain.errors[:epp_errors] }
        end
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

      def set_domain
        @domain = Domain.find_by(registrar: current_user.registrar, name: params[:id])
      end

      def set_authorized_domain
        @epp_errors ||= []
        h = {}
        h[transfer_info_params[:id].match?(/\A[0-9]+\z/) ? :id : :name] = transfer_info_params[:id]
        @domain = Domain.find_by!(h)
        return if @domain.registrar == current_user.registrar
        return if @domain.transfer_code.eql?(request.headers['Auth-Code'])

        @epp_errors << { code: 2202, msg: I18n.t('errors.messages.epp_authorization_error') }
        handle_errors
      end

      def limit
        index_params[:limit] || 200
      end

      def offset
        index_params[:offset] || 0
      end

      def index_params
        params.permit(:limit, :offset, :details)
      end
    end
  end
end
