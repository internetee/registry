module Bsa
  class AuthService
    include Bsa::ApplicationService

    def self.call
      new.call
    end

    def call
      check_for_expired_token ? build_struct(check_for_expired_token) : request_token
    end

    private

    def build_struct(token)
      Struct.new(:result?, :body).new(true, OpenStruct.new({ id_token: token }))
    end

    def request_token
      http = connect(url: base_url)
      response = http.post(endpoint, URI.encode_www_form(payload), headers)

      res = struct_response(response)

      return res unless res.result?
      
      redis.set('bsa_token', res.body.id_token)  
      res
    end

    def check_for_expired_token
      retrieved_token = redis.get("bsa_token")
      return if retrieved_token.nil?

      time = expire_token_at(retrieved_token)

      time > Time.zone.now - 1.minute ? retrieved_token : nil
    end

    def payload
      {
        'apiKey' => api_key,
        'space' => bsa
      }
    end

    def endpoint
      '/iam/api/authenticate/apiKey'
    end
  end
end
