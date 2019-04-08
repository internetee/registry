class Registrant::DomainsController < RegistrantController
  def index
    authorize! :view, :registrant_domains

    params[:q] ||= {}
    normalize_search_parameters do
      @q = current_user_domains.search(params[:q])
      @domains = @q.result.page(params[:page])
    end

    @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
  end

  def show
    @domain = current_user_domains.find(params[:id])
    authorize! :read, @domain
  end

  def confirmation
    authorize! :view, :registrant_domains
    domain = current_user_domains.find(params[:id])

    if (domain.statuses.include?(DomainStatus::PENDING_UPDATE) ||
        domain.statuses.include?(DomainStatus::PENDING_DELETE_CONFIRMATION)) &&
        domain.pending_json.present?

      @domain = domain
      @confirmation_url = confirmation_url(domain)
    else
      flash[:warning] = I18n.t('available_verification_url_not_found')
      redirect_to registrant_domain_path(domain)
    end
  end

  def download_list
    authorize! :view, :registrant_domains
    params[:q] ||= {}
    normalize_search_parameters do
      @q = current_user_domains.search(params[:q])
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

  def confirmation_url(domain)
    if domain.statuses.include?(DomainStatus::PENDING_UPDATE)
      registrant_domain_update_confirm_url(token: domain.registrant_verification_token)
    elsif domain.statuses.include?(DomainStatus::PENDING_DELETE_CONFIRMATION)
      registrant_domain_delete_confirm_url(token: domain.registrant_verification_token)
    end
  end
end