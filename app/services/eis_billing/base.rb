module EisBilling
  class Base
    BASE_URL = ENV['eis_billing_system_base_url'] || 'https://st-billing.infra.tld.ee'
    INITIATOR = 'registry'.freeze

    def self.base_request(url:)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true unless Rails.env.development?
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

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
        'Content-Type' => 'application/json',
      }
    end

    def self.billing_secret
      ENV['billing_secret']
    end
  end
end
