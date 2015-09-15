class Registrar::DomainsController < Registrar::DeppController # EPP controller
  before_action :init_domain, except: :new
  before_action :init_contacts_autocomplete_map, only: [:new, :edit, :create, :update]

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/AbcSize
  # rubocop: disable Metrics/MethodLength
  def index
    authorize! :view, Depp::Domain

    params[:q] ||= {}
    params[:q].delete_if { |_k, v| v.blank? }
    if params[:q].length == 1 && params[:q][:name_matches].present?
      @domain = Domain.find_by(name: params[:q][:name_matches])
      if @domain
        redirect_to info_registrar_domains_path(domain_name: @domain.name) and return
      end
    end

    if params[:statuses_contains]
      domains = current_user.registrar.domains.includes(:registrar, :registrant).where(
        "statuses @> ?::varchar[]", "{#{params[:statuses_contains].join(',')}}"
      )
    else
      domains = current_user.registrar.domains.includes(:registrar, :registrant)
    end

    normalize_search_parameters do
      @q = domains.search(params[:q])
      @domains = @q.result.page(params[:page])
      if @domains.count == 0 && params[:q][:name_matches] !~ /^%.+%$/
        # if we do not get any results, add wildcards to the name field and search again
        n_cache = params[:q][:name_matches]
        params[:q][:name_matches] = "%#{params[:q][:name_matches]}%"
        @q = domains.search(params[:q])
        @domains = @q.result.page(params[:page])
        params[:q][:name_matches] = n_cache # we don't want to show wildcards in search form
      end
    end

    @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i > 0
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/AbcSize

  def info
    authorize! :info, Depp::Domain
    @data = @domain.info(params[:domain_name]) if params[:domain_name]
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
  end

  def create
    authorize! :create, Depp::Domain
    @domain_params = params[:domain]
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
  end

  def update
    authorize! :update, Depp::Domain
    @domain_params = params[:domain]
    @data = @domain.update(@domain_params)

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
      render 'renew_index'
    end
  end

  def transfer
    authorize! :transfer, Depp::Domain
    if request.post? && params[:domain_name]
      @data = @domain.transfer(params)
      render 'transfer_index' and return unless response_ok?
    else
      render 'transfer_index'
    end
  end

  private

  def init_domain
    @domain = Depp::Domain.new(current_user: depp_current_user)
  end

  def init_contacts_autocomplete_map
    @contacts_autocomplete_map ||=
      current_user.registrar.contacts.pluck(:name, :code).map { |c| ["#{c.second} #{c.first}", c.second] }
    # @priv_contacts_autocomplete_map ||=
      # current_user.registrar.priv_contacts.pluck(:name, :code).map { |c| ["#{c.second} #{c.first}", c.second] }
  end

  def normalize_search_parameters
    ca_cache = params[:q][:valid_to_lteq]
    begin
      end_time = params[:q][:valid_to_lteq].try(:to_date)
      params[:q][:valid_to_lteq] = end_time.try(:end_of_day)
    rescue
      logger.warn('Invalid date')
    end

    yield

    params[:q][:valid_to_lteq] = ca_cache
  end
end
