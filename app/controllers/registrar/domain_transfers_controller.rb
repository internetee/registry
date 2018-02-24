class Registrar
  class DomainTransfersController < DeppController
    before_action do
      authorize! :transfer, Depp::Domain
    end

    def new
    end

    def create
      if params[:batch_file].present?
        csv = CSV.read(params[:batch_file].path, headers: true)
        domain_transfers = []

        csv.each do |row|
          domain_name = row['Domain']
          transfer_code = row['Transfer code']
          domain_transfers << { 'domainName' => domain_name, 'transferCode' => transfer_code }
        end

        uri = URI.parse("#{ENV['repp_url']}domain_transfers")
        request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        request.body = { data: { domainTransfers: domain_transfers } }.to_json
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
          flash[:notice] = t '.transferred', count: parsed_response[:data].size
          redirect_to registrar_domains_url
        else
          @api_errors = parsed_response[:errors]
          render :new
        end
      else
        params[:request] = true # EPP domain:transfer "op" attribute
        domain = Depp::Domain.new(current_user: depp_current_user)
        @data = domain.transfer(params)
        render :new unless response_ok?
      end
    end
  end
end
