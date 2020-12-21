class ReppApi
  def self.bulk_renew(domains, period, registrar)
    payload = { domains: domains, renew_period: period }
    uri = URI.parse("#{ENV['repp_url']}domains/renew/bulk")
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = payload.to_json
    request.basic_auth(registrar.username, registrar.plain_text_password)

    if Rails.env.test?
      response =
        Net::HTTP.start(uri.hostname, uri.port,
                        use_ssl: (uri.scheme == 'https'),
                        verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          http.request(request)
        end
    elsif Rails.env.development?
      client_cert = File.read(ENV['cert_path'])
      client_key = File.read(ENV['key_path'])
      response =
        Net::HTTP.start(uri.hostname, uri.port,
                        use_ssl: (uri.scheme == 'https'),
                        verify_mode: OpenSSL::SSL::VERIFY_NONE,
                        cert: OpenSSL::X509::Certificate.new(client_cert),
                        key: OpenSSL::PKey::RSA.new(client_key)) do |http|
          http.request(request)
        end
    else
      client_cert = File.read(ENV['cert_path'])
      client_key = File.read(ENV['key_path'])
      response =
        Net::HTTP.start(uri.hostname, uri.port,
                        use_ssl: (uri.scheme == 'https'),
                        cert: OpenSSL::X509::Certificate.new(client_cert),
                        key: OpenSSL::PKey::RSA.new(client_key)) do |http|
          http.request(request)
        end
    end
    response.body
  end
end
