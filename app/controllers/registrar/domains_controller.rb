class Registrar
  class DomainsController < DeppController
    before_action :init_domain, except: :new
    helper_method :contacts
    helper_method :search_params

    def index
      authorize! :view, Depp::Domain

      if search_params.to_h.delete_if { |_key, value| value.blank? }.length == 1 &&
        search_params[:name_matches].present?
        domain = Domain.find_by(name: search_params[:name_matches])

        if domain
          redirect_to info_registrar_domains_url(domain_name: domain.name) and return
        end
      end

      domains = if params[:statuses_contains]
                  current_registrar_user.registrar.domains
                                        .includes(:registrar, :registrant)
                                        .where('domains.statuses @> ?::varchar[]',
                                               "{#{params[:statuses_contains].join(',')}}")
                else
                  current_registrar_user.registrar.domains.includes(:registrar, :registrant)
                end

      normalize_search_parameters do
        @q = domains.search(search_params)
        @domains = @q.result.page(params[:page])

        # if we do not get any results, add wildcards to the name field and search again
        if @domains.count == 0 && search_params[:name_matches] !~ /^%.+%$/
          new_search_params = search_params.to_h
          new_search_params[:name_matches] = "%#{new_search_params[:name_matches]}%"
          @q = domains.search(new_search_params)
          @domains = @q.result.page(params[:page])
        end
      end

      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      respond_to do |format|
        format.html
        format.csv do
          domain_presenters = []

          @domains.find_each do |domain|
            domain_presenters << ::DomainPresenter.new(domain: domain, view: view_context)
          end

          raw_csv = Registrar::DomainListCSVPresenter.new(domains: domain_presenters,
                                                          view: view_context).to_s
          filename = "Domains_#{l(Time.zone.now, format: :filename)}.csv"
          send_data raw_csv, filename: filename, type: "#{Mime[:csv]}; charset=utf-8"
        end
      end
    end

    def info
      authorize! :info, Depp::Domain
      @data = @domain.info(params[:domain_name]) if params[:domain_name]
      @client_holded = client_holded(@data)
      if response_ok?
        render 'info'
      else
        flash[:alert] = @data.css('msg').text
        redirect_to registrar_domains_url and return
      end
    end

    def check
      authorize! :check, Depp::Domain
      if params[:domain_name]
        @data = @domain.check(params[:domain_name])
        render 'check_index' and return unless response_ok?
      else
        render 'check_index'
      end
    end

    def new
      authorize! :create, Depp::Domain
      @domain_params = Depp::Domain.default_params
      @domain_params[:period] = Depp::Domain.default_period
    end

    def create
      authorize! :create, Depp::Domain
      @domain_params = domain_params.to_h
      @data = @domain.create(@domain_params)

      if response_ok?
        redirect_to info_registrar_domains_url(domain_name: @domain_params[:name])
      else
        render 'new'
      end
    end

    def edit
      authorize! :update, Depp::Domain
      @data = @domain.info(params[:domain_name])
      @domain_params = Depp::Domain.construct_params_from_server_data(@data)
      @dispute = Dispute.active.find_by(domain_name: params[:domain_name])
    end

    def update
      authorize! :update, Depp::Domain
      @domain_params = params[:domain]
      @data = @domain.update(@domain_params)
      @dispute = Dispute.active.find_by(domain_name: @domain_params[:name])

      if response_ok?
        redirect_to info_registrar_domains_url(domain_name: @domain_params[:name])
      else
        params[:domain_name] = @domain_params[:name]
        render 'new'
      end
    end

    def delete
      authorize! :delete, Depp::Domain
    end

    def destroy
      authorize! :delete, Depp::Domain
      @data = @domain.delete(params[:domain])
      @results = @data.css('result')
      if response_ok?
        redirect_to info_registrar_domains_url(domain_name: params[:domain][:name])
      else
        params[:domain_name] = params[:domain][:name]
        render 'delete'
      end
    end

    def renew
      authorize! :renew, Depp::Domain
      if params[:domain_name] && params[:cur_exp_date]
        @data = @domain.renew(params)
        render 'renew_index' and return unless response_ok?
      else
        params[:period] = Depp::Domain.default_period
        render 'renew_index'
      end
    end

    def search_contacts
      authorize! :create, Depp::Domain

      scope = current_registrar_user.registrar.contacts.limit(10)
      if params[:query].present?
        escaped_str = ActiveRecord::Base.connection.quote_string params[:query]
        scope = scope.where("name ilike '%#{escaped_str}%' OR code ilike '%#{escaped_str}%' ")
      end

      render json: scope.pluck(:name, :code).map { |c| { display_key: "#{c.second} #{c.first}", value: c.second } }
    end

    def remove_hold
      authorize! :remove_hold, Depp::Domain
      return unless params[:domain_name]

      @data = @domain.remove_hold(params)

      flash[:alert] = @data.css('msg').text unless response_ok?
      redirect_to info_registrar_domains_url(domain_name: params[:domain_name])
    end

    private

    def init_domain
      @domain = Depp::Domain.new(current_user: depp_current_user)
    end

    def client_holded(data)
      data.css('status')&.map { |element| element.attribute('s').value }
         &.any? { |status| status == DomainStatus::CLIENT_HOLD }
    end

    def contacts
      current_registrar_user.registrar.contacts
    end

    def normalize_search_parameters
      ca_cache = search_params[:valid_to_lteq]
      begin
        end_time = search_params[:valid_to_lteq].try(:to_date)
        search_params[:valid_to_lteq] = end_time.try(:end_of_day)
      rescue
        logger.warn('Invalid date')
      end

      yield

      search_params[:valid_to_lteq] = ca_cache
    end

    def search_params
      params.fetch(:q, {}).permit(:name_matches,
                                  :registrant_ident_eq,
                                  :contacts_ident_eq,
                                  :nameservers_hostname_eq,
                                  :valid_to_gteq,
                                  :valid_to_lteq,
                                  :s)
    end

    def domain_params
      params.require(:domain).permit(:name, :period, :registrant, :registrant_helper, :reserved_pw,
                                     :verified, :legal_document, contacts_attributes: {},
                                                                 nameservers_attributes: {},
                                                                 dnskeys_attributes: {})
    end
  end
end
