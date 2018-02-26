class Registrar
  class RegistrarNameserversController < DeppController
    def edit
      authorize! :manage, :repp
    end

    def update
      authorize! :manage, :repp

      ipv4 = params[:ipv4].split("\r\n")
      ipv6 = params[:ipv6].split("\r\n")

      uri = URI.parse("#{ENV['repp_url']}registrar/nameservers")
      request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      request.body = { data: { type: 'nameserver', id: params[:old_hostname],
                               attributes: { hostname: params[:new_hostname],
                                             ipv4: ipv4,
                                             ipv6: ipv6 } } }.to_json
      request.basic_auth(current_user.username, current_user.password)

      if Rails.env.test?
        response = Net::HTTP.start(uri.hostname, uri.port,
                                   use_ssl: (uri.scheme == 'https'),
                                   verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          http.request(request)
        end
      elsif Rails.env.development?
        client_cert = File.read(ENV['cert_path'])
        client_key = File.read(ENV['key_path'])
        response = Net::HTTP.start(uri.hostname, uri.port,
                                   use_ssl: (uri.scheme == 'https'),
                                   verify_mode: OpenSSL::SSL::VERIFY_NONE,
                                   cert: OpenSSL::X509::Certificate.new(client_cert),
                                   key: OpenSSL::PKey::RSA.new(client_key)) do |http|
          http.request(request)
        end
      else
        client_cert = File.read(ENV['cert_path'])
        client_key = File.read(ENV['key_path'])
        response = Net::HTTP.start(uri.hostname, uri.port,
                                   use_ssl: (uri.scheme == 'https'),
                                   cert: OpenSSL::X509::Certificate.new(client_cert),
                                   key: OpenSSL::PKey::RSA.new(client_key)) do |http|
          http.request(request)
        end
      end

      parsed_response = JSON.parse(response.body, symbolize_names: true)

      if response.code == '200'
        flash[:notice] = t '.replaced'
        redirect_to registrar_domains_url
      else
        @api_errors = parsed_response[:errors]
        render :edit
      end
    end
  end
end
