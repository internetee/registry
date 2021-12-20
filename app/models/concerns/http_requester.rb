module HttpRequester
  extend ActiveSupport::Concern

  HTTP_METHODS = {
    get: Net::HTTP::Get,
    post: Net::HTTP::Post,
  }.freeze

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Errno::ECONNREFUSED,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
  ].freeze

  def default_request_response(url:, body:, headers:, type: :post)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (url.scheme == 'https')

    generate_request(body: body, headers: headers, http: http, type: type, uri: uri)
  rescue *HTTP_ERRORS => e
    failed_result(e)
  end

  def generate_request(body:, headers:, http:, type:, uri:)
    Timeout.timeout(10) do
      request = HTTP_METHODS[type].new(uri.request_uri)
      headers&.each { |key, val| request[key] = val }
      request.body = body.to_json if body
      success_result(response: http.request(request))
    end
  end

  def success_result(response:)
    {
      body: JSON.parse(response.read_body),
      status: response.code.to_i,
    }
  end

  def failed_result(exception)
    error_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[:service_unavailable]
    {
      body: "Error occured - #{exception.message}",
      status: error_code,
    }
  end

  def default_post_request_response(url:, body: nil, headers: nil)
    default_request_response(url: url, body: body, headers: headers, type: :post)
  end

  def default_get_request_response(url:, body: nil, headers: nil)
    default_request_response(url: url, body: body, headers: headers, type: :get)
  end

  # :nocov:
  def basic_auth_get(url:, username:, password:)
    uri = URI(url)

    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth username, password
      response = http.request request

      JSON.parse(response.body)
    end
  end
  # :nocov:
end
