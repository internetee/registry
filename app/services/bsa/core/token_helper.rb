module Bsa
  module Core
    module TokenHelper
      def token
        response = Bsa::AuthService.call
  
        if response.result?
          response.body.id_token
        else
          raise Bsa::AuthError, "#{response.error.message}: #{response.error.description}"
        end
      end
    end
  end
end
