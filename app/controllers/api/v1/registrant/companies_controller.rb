require 'serializers/registrant_api/company'

module Api
  module V1
    module Registrant
      class CompaniesController < ::Api::V1::Registrant::BaseController
        MAX_LIMIT = 200
        MIN_OFFSET = 0

        def index
          result = error_result('limit') if limit > MAX_LIMIT || limit < 1
          result = error_result('offset') if offset < MIN_OFFSET
          result ||= companies_result(limit, offset)

          render result
        end

        def current_user_companies
          current_registrant_user.companies
        rescue CompanyRegister::NotAvailableError
          []
        end

        def limit
          (params[:limit] || MAX_LIMIT).to_i
        end

        def offset
          (params[:offset] || MIN_OFFSET).to_i
        end

        def error_result(attr_name)
          { json: { errors: [{ attr_name.to_sym => ['parameter is out of range'] }] },
            status: :bad_request }
        end

        def companies_result(limit, offset)
          @companies = current_user_companies.drop(offset).first(limit)
          status = @companies.present? ? :ok : :not_found

          serialized_companies = @companies.map do |item|
            country_code = current_registrant_user.country.alpha3
            serializer = ::Serializers::RegistrantApi::Company.new(company: item,
                                                                   country_code: country_code)
            serializer.to_json
          end
          { json: { companies: serialized_companies }, status: status }
        end
      end
    end
  end
end
