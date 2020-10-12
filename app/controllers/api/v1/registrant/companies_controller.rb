require 'serializers/registrant_api/company'

module Api
  module V1
    module Registrant
      class CompaniesController < ::Api::V1::Registrant::BaseController
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

          @companies = current_user_companies.drop(offset.to_i).first(limit.to_i)

          serialized_companies = @companies.map do |item|
            country_code = current_registrant_user.country.alpha3
            serializer = ::Serializers::RegistrantApi::Company.new(company: item,
                                                                   country_code: country_code)
            serializer.to_json
          end

          render json: serialized_companies
        end

        def current_user_companies
          current_registrant_user.companies
        rescue CompanyRegister::NotAvailableError
          nil
        end
      end
    end
  end
end
