class Registrar
  class NameserversController < BulkChangeController
    def update
      authorize! :manage, :repp

      ipv4 = params[:ipv4].split("\r\n")
      ipv6 = params[:ipv6].split("\r\n")

      uri = URI.parse("#{ENV['repp_url']}registrar/nameservers")

      domains = domain_list_from_csv

      return csv_list_empty_guard if domains == []

      options = {
        uri: uri,
        ipv4: ipv4,
        ipv6: ipv6,
      }
      action = Actions::BulkNameserversChange.new(params, domains, current_registrar_user, options)
      response = action.call

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

      notices << "#{t('.skipped_domains')}: #{res[:data][:skipped_domains].join(', ')}" if res[:data][:skipped_domains]

      notices.join(', ')
    end

    def csv_list_empty_guard
      notice = 'CSV scoped domain list seems empty. Make sure that domains are added and ' \
      '"domain_name" header is present.'
      redirect_to(registrar_domains_url, flash: { notice: notice })
    end

    def domain_list_from_csv
      return if params[:puny_file].blank?

      domains = []
      csv = CSV.read(params[:puny_file].path, headers: true)

      return [] if csv['domain_name'].blank?

      csv.map { |b| domains << b['domain_name'] }

      domains.compact
    rescue CSV::MalformedCSVError
      []
    end
  end
end
