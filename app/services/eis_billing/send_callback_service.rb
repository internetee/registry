module EisBilling
  class SendCallbackService < EisBilling::Base

    attr_reader :reference_number

    def initialize(reference_number:)
      @reference_number = reference_number
    end

    def self.call(reference_number:)
      new(reference_number: reference_number).call
    end

    def call
      send_request
    end

    private

    def send_request
      http = EisBilling::Base.base_request
      http.get(billing_callback_url)
    end

    def billing_callback_url
      "/api/v1/callback_handler/callback?payment_reference=#{reference_number}"
    end
  end
end
