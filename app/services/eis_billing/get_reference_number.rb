module EisBilling
  class GetReferenceNumber < EisBilling::Base
    attr_reader :owner

    # rubocop:disable Lint/MissingSuper
    def initialize(owner:)
      @owner = owner
    end

    def self.call(owner:)
      new(owner: owner).call
    end

    def call
      http = EisBilling::Base.base_request(url: reference_number_generator_url)
      http.post(reference_number_generator_url, payload.to_json, EisBilling::Base.headers)
    end

    def payload
      {
        initiator: INITIATOR,
        owner: owner
      }
    end

    def reference_number_generator_url
      "#{EisBilling::Base::BASE_URL}/api/v1/invoice_generator/reference_number_generator"
    end
  end
end
