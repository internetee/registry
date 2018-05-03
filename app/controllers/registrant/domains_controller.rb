class Registrant::DomainsController < RegistrantController
  def index
    authorize! :view, :registrant_domains
    params[:q] ||= {}
    normalize_search_parameters do
      @q = domains.search(params[:q])
      @domains = @q.result.page(params[:page])
    end
    @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
  end

  def show
    @domain = domains.find(params[:id])
    authorize! :read, @domain
  end

  def domain_verification_url
    authorize! :view, :registrant_domains
    dom = domains.find(params[:id])
    if (dom.statuses.include?(DomainStatus::PENDING_UPDATE) || dom.statuses.include?(DomainStatus::PENDING_DELETE_CONFIRMATION)) &&
      dom.pending_json.present?

      @domain = dom
      confirm_path = get_confirm_path(dom.statuses)
      @verification_url = "#{confirm_path}/#{@domain.id}?token=#{@domain.registrant_verification_token}"

    else
      flash[:warning] = I18n.t('available_verification_url_not_found')
      redirect_to registrant_domain_path(dom.id)
    end
  end

  def download_list
    authorize! :view, :registrant_domains
    params[:q] ||= {}
    normalize_search_parameters do
      @q = domains.search(params[:q])
      @domains = @q
    end

    respond_to do |format|
      format.csv { render text: @domains.result.to_csv }
      format.pdf do
        pdf = @domains.result.pdf(render_to_string('registrant/domains/download_list', layout: false))
        send_data pdf, filename: 'domains.pdf'
      end
    end
  end

  private

  def set_domain
    @domain = domains.find(params[:id])
  end

  def domains
    ident_cc, ident = @current_user.registrant_ident.split '-'
    begin
      BusinessRegistryCache.fetch_associated_domains ident, ident_cc
    rescue Soap::Arireg::NotAvailableError => error
      flash[:notice] = I18n.t(error.json[:message])
      Rails.logger.fatal("[EXCEPTION] #{error.to_s}")
      current_user.domains
    end
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

  def get_confirm_path(statuses)
    if statuses.include?(DomainStatus::PENDING_UPDATE)
      "#{ENV['registrant_url']}/registrant/domain_update_confirms"
    elsif statuses.include?(DomainStatus::PENDING_DELETE_CONFIRMATION)
      "#{ENV['registrant_url']}/registrant/domain_delete_confirms"
    end
  end
end
