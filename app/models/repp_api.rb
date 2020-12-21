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
    http = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https'))
    unless Rails.env.test?
      http.cert = OpenSSL::X509::Certificate.new(File.read(ENV['cert_path']))
      http.key = OpenSSL::PKey::RSA.new(File.read(ENV['key_path']))
    end
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env.development? || Rails.env.test?

    http.request(request)
  end
end
