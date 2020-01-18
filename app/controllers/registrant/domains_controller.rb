class Registrant::DomainsController < RegistrantController
  def index
    authorize! :view, :registrant_domains

    params[:q] ||= {}
    normalize_search_parameters do
      @q = current_user_domains.search(search_params)
    end

    domains = @q.result

    respond_to do |format|
      format.html do
        @domains = domains.page(params[:page])
        domains_per_page = params[:results_per_page].to_i
        @domains = @domains.per(domains_per_page) if domains_per_page.positive?
      end
      format.csv do
        raw_csv = @q.result.to_csv
        send_data raw_csv, filename: 'domains.csv', type: "#{Mime[:csv]}; charset=utf-8"
      end
      format.pdf do
        view = ActionView::Base.new(ActionController::Base.view_paths, domains: domains)
        raw_html = view.render(file: 'registrant/domains/list_pdf', layout: false)
        raw_pdf = domains.pdf(raw_html)

        send_data raw_pdf, filename: 'domains.pdf'
      end
    end
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

  def search_params
    params.require(:q).permit(:name_matches, :registrant_ident_eq, :valid_to_gteq, :valid_to_lteq,
                              :results_per_page)
  end
end
