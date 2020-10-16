module Serializers
  module RegistrantApi
    class Company
      attr_reader :company, :country_code

      def initialize(company:, country_code:)
        @company = company
        @country_code = country_code
      end

      def to_json(*_args)
        {
          name: company.company_name,
          registry_no: company.registration_number,
          country_code: @country_code,
        }
      end
    end
  end
end
