module EisBilling
  class GetReferenceNumber < EisBilling::Base
    attr_reader :owner, :initiator

    # rubocop:disable Lint/MissingSuper
    def initialize(owner:, initiator: INITIATOR)
      @owner = owner
      @initiator = initiator
    end

    def self.call(owner:, initiator: INITIATOR)
      new(owner: owner, initiator: initiator).call
    end

    def call
      http = EisBilling::Base.base_request
      http.post(reference_number_generator_url, payload.to_json, EisBilling::Base.headers)
    end

    def payload
      {
        initiator: initiator,
        owner: owner
      }
    end

    def reference_number_generator_url
      "#{EisBilling::Base::BASE_URL}/api/v1/invoice_generator/reference_number_generator"
    end
  end
end
