module Bsa
  class BlockOrderListService
    include Bsa::ApplicationService

    attr_reader :sort_by, :order, :offset, :limit, :q

    def self.call(sort_by: nil, order: nil, offset: nil, limit: nil, q: {})
      new(sort_by: sort_by, order: order, offset: offset, limit: limit, q: q).call
    end

    def initialize(sort_by:, order:, offset:, limit:, q:)
      @sort_by = sort_by
      @order = order
      @offset = offset
      @limit = limit
      @q = q
    end

    def call
      http = connect(url: base_url)
      response = http.get(endpoint, headers.merge(token_format(token)))

      struct_response(response)
    end

    private

    def token
      response = Bsa::AuthService.call

      if response.result?
        response.body.id_token
      else
        raise Bsa::AuthError, "#{response.error.message}: #{response.error.description}"
      end
    end

    def endpoint
      "/bsa/api/blockrsporder?#{query_string}"
    end

    def query_string
      params = {
        'sortBy' => @sort_by,
        'order' => @order,
        'offset' => @offset,
        'limit' => @limit
      }.merge(@q).compact
    
      URI.encode_www_form(params)
    end
  end
end
