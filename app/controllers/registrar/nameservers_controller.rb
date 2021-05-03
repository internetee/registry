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

      response = do_request(request, uri)

      parsed_response = JSON.parse(response.body, symbolize_names: true)

      if response.code == '200'
        redirect_to(registrar_domains_url,
                    flash: { notice: compose_notice_message(parsed_response) })
      else
        @api_errors = parsed_response[:message]
        render 'registrar/bulk_change/new', locals: { active_tab: :nameserver }
      end
    end

    def compose_notice_message(res)
      notices = ["#{t('.replaced')}. #{t('.affected_domains')}: " \
      "#{res[:data][:affected_domains].join(', ')}"]

      if res[:data][:skipped_domains]
        notices << "#{t('.skipped_domains')}: #{res[:data][:skipped_domains].join(', ')}"
      end

      notices.join(', ')
    end

    def domain_list_from_csv
      return [] if params[:puny_file].blank?

      domains = []
      CSV.read(params[:puny_file].path, headers: true).each { |b| domains << b['domain_name'] }
      domains
    end
  end
end
