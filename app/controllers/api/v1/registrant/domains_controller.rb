require 'serializers/registrant_api/domain'

module Api
  module V1
    module Registrant
      class DomainsController < ::Api::V1::Registrant::BaseController
        before_action :set_tech_flag, only: [:show]

        LIMIT_DOMAIN_TOTAL = 3000.freeze

        def index
          limit = params[:limit] || 200
          offset = params[:offset] || 0
          simple = params[:simple] == 'true' || false         

          if limit.to_i > 200 || limit.to_i < 1
            render(json: { errors: [{ limit: ['parameter is out of range'] }] },
                   status: :bad_request) && return
          end

          if offset.to_i.negative?
            render(json: { errors: [{ offset: ['parameter is out of range'] }] },
                   status: :bad_request) && return
          end

          domains = current_user_domains
          serialized_domains = domains.limit(limit).offset(offset).map do |item|
            serializer = Serializers::RegistrantApi::Domain.new(item, simplify: simple)
            serializer.to_json
          end

          render json: { total: current_user_domains_total_count, count: domains.count,
                         domains: serialized_domains }
        end

        def show
          @domain = current_user_domains.find_by(uuid: params[:uuid])

          if @domain
            serializer = Serializers::RegistrantApi::Domain.new(@domain, simplify: false)
            render json: serializer.to_json
          else
            render json: { errors: [{ base: ['Domain not found'] }] }, status: :not_found
          end
        end

        private

        def set_tech_flag
          # current_user_domains scope depends on tech flag
          # However, if it's not present, tech contact can not see specific domain entry at all.
          params.merge!(tech: 'true')
        end

        def current_user_domains_total_count
          current_registrant_user.domains.count
        rescue CompanyRegister::NotAvailableError
          current_registrant_user.direct_domains.count
        end

        def current_user_domains
          return initialization_count_of__domains if params[:tech] == 'init'

          current_registrant_user.domains(admin: params[:tech] != 'true')
        rescue CompanyRegister::NotAvailableError
          return initialization_count_of__direct_domains if params[:tech] == 'init'

          current_registrant_user.direct_domains(admin: params[:tech] != 'true')
        end

        def initialization_count_of__direct_domains
          return current_registrant_user.direct_domains(admin: false) if current_user_domains_total_count < LIMIT_DOMAIN_TOTAL
          current_registrant_user.direct_domains(admin: true)
        end

        def initialization_count_of__domains
          return current_registrant_user.domains(admin: false) if current_user_domains_total_count < LIMIT_DOMAIN_TOTAL
          current_registrant_user.domains(admin: true)
        end
      end
    end
  end
end
