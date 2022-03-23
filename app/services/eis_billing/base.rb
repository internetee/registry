module EisBilling
  class Base
    BASE_URL = ENV['eis_billing_system_base_url']
    INITIATOR = 'registry'.freeze

    def self.base_request(url:)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)

      unless Rails.env.development? || Rails.env.test?
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
      Rails.application.credentials.config[:billing_secret]
    end
  end
end
