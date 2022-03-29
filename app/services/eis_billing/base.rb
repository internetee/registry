module EisBilling
  class Base
    BASE_URL = ENV['eis_billing_system_base_url']
    INITIATOR = 'registry'.freeze

    def self.base_request(url:)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)

      if Rails.env.production?
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http
    end

    def self.generate_token
      JWT.encode(payload, billing_secret)
    end

    def self.payload
      { initiator: INITIATOR }
    end

    def self.headers
      {
        'Authorization' => "Bearer #{generate_token}",
        'Content-Type' => 'application/json'
      }
    end

    def self.billing_secret
      ENV['billing_secret']
    end
  end
end
