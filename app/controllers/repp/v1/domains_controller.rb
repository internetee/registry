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

      private

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
