# frozen_string_literal: true

module Eeid
  class IdentError < StandardError; end

  # Base class for handling EEID identification requests.
  class Base
    BASE_URL = ENV['eeid_base_url']
    TOKEN_ENDPOINT = '/api/auth/v1/token'

    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
      @token = nil
    end

    def request_endpoint(endpoint, method: :get, body: nil)
      Rails.logger.debug("Requesting endpoint: #{endpoint} with method: #{method}")
      authenticate unless @token
      request = build_request(endpoint, method, body)
      response = send_request(request)
      handle_response(response)
    rescue StandardError => e
      handle_error(e)
    end

    def authenticate
      Rails.logger.debug("Authenticating with client_id: #{@client_id}")
      uri = URI.parse("#{BASE_URL}#{TOKEN_ENDPOINT}")
      request = build_auth_request(uri)

      response = send_auth_request(uri, request)
      handle_auth_response(response)
    end

    private

    def build_auth_request(uri)
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Basic #{Base64.strict_encode64("#{@client_id}:#{@client_secret}")}"
      request
    end

    def send_auth_request(uri, request)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: ssl_enabled?) do |http|
        Rails.logger.debug("Sending authentication request to #{uri}")
        http.request(request)
      end
    end

    def handle_auth_response(response)
      raise IdentError, "Authentication failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      @token = JSON.parse(response.body)['access_token']
      Rails.logger.debug('Authentication successful, token received')
    end

    def build_request(endpoint, method, body)
      uri = URI.parse("#{BASE_URL}#{endpoint}")
      request = create_request(uri, method)
      request['Authorization'] = "Bearer #{@token}"
      request.body = body.to_json if body
      request.content_type = 'application/json'

      request
    end

    def create_request(uri, method)
      case method.to_sym
      when :get
        Net::HTTP::Get.new(uri)
      when :post
        Net::HTTP::Post.new(uri)
      else
        raise IdentError, "Unsupported HTTP method: #{method}"
      end
    end

    def send_request(request)
      uri = URI.parse(request.uri.to_s)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: ssl_enabled?) do |http|
        Rails.logger.debug("Sending #{request.method} request to #{uri} with body: #{request.body}")
        http.request(request)
      end
    end

    def handle_response(response)
      parsed_response = JSON.parse(response.body)
      raise IdentError, parsed_response['error'] unless response.is_a?(Net::HTTPSuccess)

      Rails.logger.debug("Request successful: #{response.body}")
      parsed_response
    end

    def handle_error(exception)
      raise IdentError, exception.message
    end

    def ssl_enabled?
      !%w[test].include?(Rails.env)
    end
  end
end
