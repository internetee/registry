class ReppApi
  def self.bulk_renew(domains, period, registrar)
    payload = { domains: domains, renew_period: period }
    uri = URI.parse("#{ENV['repp_url']}domains/renew/bulk")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = payload.to_json

    ReppApi.request(req, uri, registrar: registrar).body
  end

  def self.request(request, uri, registrar:)
    request.basic_auth(registrar.username, registrar.plain_text_password) if registrar
    client_cert = Rails.env.test? ? nil : File.read(ENV['cert_path'])
    client_key = Rails.env.test? ? nil : File.read(ENV['key_path'])
    params = ReppApi.compose_ca_auth_params(uri, client_cert, client_key)

    Net::HTTP.start(uri.hostname, uri.port, params) do |http|
      http.request(request)
    end
  end

  def self.compose_ca_auth_params(uri, client_cert, client_key)
    params = { use_ssl: (uri.scheme == 'https') }
    params[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if Rails.env.test? || Rails.env.development?

    unless Rails.env.test?
      params[:cert] = OpenSSL::X509::Certificate.new(client_cert)
      params[:key] = OpenSSL::PKey::RSA.new(client_key)
    end

    params
  end
end
