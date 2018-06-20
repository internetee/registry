class Registrar
  class TechContactsController < BulkChangeController
    def update
      authorize! :manage, :repp

      uri = URI.parse("#{ENV['repp_url']}domains/contacts")

      request = Net::HTTP::Patch.new(uri)
      request.set_form_data(current_contact_id: params[:current_contact_id],
                            new_contact_id: params[:new_contact_id])
      request.basic_auth(current_registrar_user.username, current_registrar_user.password)

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

        if parsed_response[:skipped_domains]
          notices << "#{t('.skipped_domains')}: #{parsed_response[:skipped_domains].join(', ')}"
        end

        flash[:notice] = notices
        redirect_to registrar_domains_url
      else
        @error = parsed_response[:error]
        render file: 'registrar/bulk_change/new', locals: { active_tab: :technical_contact }
      end
    end
  end
end
