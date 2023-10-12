module Bsa
  class NonBlockedNameActionService
    include ApplicationService
    include Core::TokenHelper

    attr_reader :action, :suborder_id, :payload

    # Actions:
    # - add
    # - remove
    # - remove_all

    def self.call(action:, suborder_id:, payload:)
      new(action: action, suborder_id: suborder_id, payload: payload).call
    end

    def initialize(action:, suborder_id:, payload:)
      @action = action
      @suborder_id = suborder_id
      @payload = payload
    end

    def call
      http = connect(url: base_url)
      response = http.post(endpoint, payload.to_json, headers(content_type: 'json').merge(token_format(token)))

      struct_response(response)
    end

    private

    def endpoint
      if action == 'remove_all'
        "/bsa/api/blockrsporder/#{suborder_id}/nonblockednames?action=remove"
      else
        "/bsa/api/blockrsporder/nonblockednames?#{query_string}"
      end
    end

    def query_string
      params = {
        'action' => action,
        'suborderid' => suborder_id
      }.compact

      URI.encode_www_form(params)
    end
  end
end
