module Bsa
  module Core
    module TokenHelper
      def token
        response = Bsa::AuthService.call

        raise Bsa::AuthError, "#{response.error.message}: #{response.error.description}" unless response.result?

        response.body.id_token
      end
    end
  end
end
