class Registrar
  class BulkChangeController < DeppController
    helper_method :available_contacts

    def new
      authorize! :manage, :repp
      @expire_date = Time.zone.now.to_date
      render file: 'registrar/bulk_change/new', locals: { active_tab: default_tab }
    end

    def bulk_renew
      authorize! :manage, :repp
      set_form_data

      if ready_to_renew?
        res = ReppApi.bulk_renew(domain_ids_for_bulk_renew, params[:period],
                                 current_registrar_user)

        flash_message(JSON.parse(res))
      else
        flash[:notice] = nil
      end

      render file: 'registrar/bulk_change/new', locals: { active_tab: :bulk_renew }
    end

    private

    def process_response(response:, start_notice: '', active_tab:)
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      if response.code == '200'
        notices = success_notices(parsed_response, start_notice)

        flash[:notice] = notices.join(', ')
        redirect_to registrar_domains_url
      else
        @error = response.code == '404' ? 'Contact(s) not found' : parsed_response[:message]
        render file: 'registrar/bulk_change/new', locals: { active_tab: active_tab }
      end
    end

    def success_notices(parsed_response, start_notice)
      notices = [start_notice]

      notices << "#{t('.affected_domains')}: " \
                   "#{parsed_response[:data][:affected_domains].join(', ')}"

      if parsed_response[:data][:skipped_domains]
        notices << "#{t('.skipped_domains')}: " \
                     "#{parsed_response[:data][:skipped_domains].join(', ')}"
      end
      notices
    end

    def do_request(request, uri)
      response = if Rails.env.test?
                   do_test_request(request, uri)
                 elsif Rails.env.development?
                   do_dev_request(request, uri)
                 else
                   do_live_request(request, uri)
                 end
      response
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

    def ready_to_renew?
      domain_ids_for_bulk_renew.present? && params[:renew].present?
    end

    def set_form_data
      @expire_date = params[:expire_date].to_date
      @domains = domains_by_date(@expire_date)
      @period = params[:period]
    end

    def available_contacts
      current_registrar_user.registrar.contacts.order(:name).pluck(:name, :code)
    end

    def default_tab
      :technical_contact
    end

    def domains_scope
      current_registrar_user.registrar.domains
    end

    def domains_by_date(date)
      domains_scope.where('valid_to <= ?', date)
    end

    def domain_ids_for_bulk_renew
      params.dig('domain_ids')&.reject { |id| id.blank? }
    end

    def renew_task(domains)
      Domains::BulkRenew::Start.run(domains: domains,
                                    period_element: @period,
                                    registrar: current_registrar_user.registrar)
    end

    def flash_message(res)
      flash[:notice] = res['code'] == 1000 ? t(:bulk_renew_completed) : res['message']
    end
  end
end
