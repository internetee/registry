module Actions
  class DoRequest
    def initialize(request, uri)
      @request = request
      @uri = uri
    end

    def call
      if Rails.env.test?
        do_test_request(@request, @uri)
      elsif Rails.env.development?
        do_dev_request(@request, @uri)
      else
        do_live_request(@request, @uri)
      end

    rescue StandardError, OpenURI::HTTPError => e
      Rails.logger.debug e.message
    end

    def do_live_request(request, uri)
      client_cert = File.read(ENV['cert_path'])
      client_key = File.read(ENV['key_path'])
      Net::HTTP.start(uri.hostname, uri.port,
                      use_ssl: (uri.scheme == 'https'),
                      cert: OpenSSL::X509::Certificate.new(client_cert),
                      key: OpenSSL::PKey::RSA.new(client_key)) do |http|
        http.request(request)
      end
    end

    def do_dev_request(request, uri)
      client_cert = File.read(ENV['cert_path'])
      client_key = File.read(ENV['key_path'])
      Net::HTTP.start(uri.hostname, uri.port,
                      use_ssl: (uri.scheme == 'https'),
                      verify_mode: OpenSSL::SSL::VERIFY_NONE,
                      cert: OpenSSL::X509::Certificate.new(client_cert),
                      key: OpenSSL::PKey::RSA.new(client_key)) do |http|
        http.request(request)
      end
    end

    def do_test_request(request, uri)
      Net::HTTP.start(uri.hostname, uri.port,
                      use_ssl: (uri.scheme == 'https'),
                      verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.request(request)
      end
    end
  end
end
