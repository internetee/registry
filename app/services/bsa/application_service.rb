# frozen_string_literal: true

module Bsa
  module ApplicationService
    include Core::Errors
    include Core::Settings

    OK = '200'

    def connect(url:)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      http
    end

    def headers(content_type: 'x-www-form-urlencoded')
      {
        'Content-Type' => "application/#{content_type}",
      }
    end

    def token_format(token)
      {
        'Authorization' => "Bearer #{token}",
      }
    end

    def struct_response(response)
      parsed_data = parse_response(response)
      result = response.code == OK

      return Struct.new(:result?, :body).new(result, OpenStruct.new(parsed_data)) if result

      Struct.new(:result?, :error).new(result, OpenStruct.new(parsed_data))
    end

    def parse_response(response)
      JSON.parse(response.body)
    end

    def expire_token_at(token)
      header_enc, payload_enc, signature = token.split('.')
      payload_dec = Base64.urlsafe_decode64(payload_enc)
      payload_json = Zlib::GzipReader.new(StringIO.new(payload_dec)).read
      payload = JSON.parse(payload_json)
      
      Time.at(payload['exp']).utc.in_time_zone
    end

    def redis
      @redis ||= Redis.new(host: redist_host, port: redis_port, db: redis_db)
    end
  end
end
