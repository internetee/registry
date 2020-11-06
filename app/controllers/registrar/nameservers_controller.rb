class Registrar
  class NameserversController < BulkChangeController
    def update
      authorize! :manage, :repp

      ipv4 = params[:ipv4].split("\r\n")
      ipv6 = params[:ipv6].split("\r\n")

      domains = domain_list_from_csv

      uri = URI.parse("#{ENV['repp_url']}registrar/nameservers")
      request = Net::HTTP::Put.new(uri, 'Content-Type' => 'application/json')
      request.body = { data: { type: 'nameserver', id: params[:old_hostname],
                               domains: domains,
                               attributes: { hostname: params[:new_hostname],
                                             ipv4: ipv4,
                                             ipv6: ipv6 } } }.to_json
      request.basic_auth(current_registrar_user.username,
                         current_registrar_user.plain_text_password)

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
        notices = [t('.replaced')]
        notices << "#{t('.affected_domains')}: #{parsed_response[:affected_domains].join(', ')}"

        flash[:notice] = notices
        redirect_to registrar_domains_url
      else
        @api_errors = parsed_response[:errors]
        render file: 'registrar/bulk_change/new', locals: { active_tab: :nameserver }
      end
    end

    def domain_list_from_csv
      return [] if params[:puny_file].blank?

      domains = []
      CSV.read(params[:puny_file].path, headers: true).each { |b| domains << b['domain_name'] }
      domains
    end
  end
end
