module Bsa
  class BlockOrderViewService
    include ApplicationService
    include Core::TokenHelper

    attr_reader :block_suborder_id, :offset, :limit

    def self.call(block_suborder_id: nil, offset: nil, limit: nil)
      new(block_suborder_id: block_suborder_id, offset: offset, limit: limit).call
    end

    def initialize(block_suborder_id:, offset:, limit:)
      @block_suborder_id = block_suborder_id
      @offset = offset
      @limit = limit
    end

    def call
      http = connect(url: base_url)
      response = http.get(endpoint, headers.merge(token_format(token)))

      struct_response(response)
    end

    private

    def endpoint
      "/bsa/api/blockrsporder/labels?#{query_string}"
    end

    def query_string
      params = {
        'blocksuborderid' => block_suborder_id,
        'offset' => offset,
        'limit' => limit
      }.compact
    
      URI.encode_www_form(params)
    end
  end
end
