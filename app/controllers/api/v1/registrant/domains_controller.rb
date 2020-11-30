require 'serializers/registrant_api/domain'

module Api
  module V1
    module Registrant
      class DomainsController < ::Api::V1::Registrant::BaseController
        def index
          limit = params[:limit] || 200
          offset = params[:offset] || 0

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
            serializer = Serializers::RegistrantApi::Domain.new(item, simplify: true)
            serializer.to_json
          end

          render json: { count: domains.count, domains: serialized_domains }
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

        def current_user_domains
          current_registrant_user.domains
        rescue CompanyRegister::NotAvailableError
          current_registrant_user.direct_domains
        end
      end
    end
  end
end
