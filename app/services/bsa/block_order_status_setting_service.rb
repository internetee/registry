module Bsa
  class BlockOrderStatusSettingService
    include ApplicationService
    include Core::TokenHelper

    attr_reader :payload

    def self.call(payload: [])
      new(payload: payload).call
    end

    def initialize(payload:)
      @payload = payload
    end

    def call
      http = connect(url: base_url)
      response = http.post(endpoint, payload.to_json, headers(content_type: 'json').merge(token_format(token)))

      struct_response(response)
    end

    private

    def endpoint
      '/bsa/api/blockrsporder/status'
    end
  end
end
