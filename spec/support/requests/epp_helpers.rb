module Requests
  module EPPHelpers
    def valid_legal_document
      Base64.encode64('a' * 5000)
    end
  end
end
