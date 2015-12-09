class Registrant::DomainsController < RegistrantController

  def index
  authorize! :view, :registrant_domains
  params[:q] ||= {}
  domains = current_user.domains
  normalize_search_parameters do
    @q = domains.search(params[:q])
    @domains = @q.result.page(params[:page])
  end
  @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i > 0
  end

  def show
    @domain = Domain.find(params[:id])
    if !(current_user.domains.include?(@domain) || @domain.valid?)
      redirect_to registrant_domains_path
    end
    authorize! :read, @domain
  end

  def set_domain
    @domain = Domain.find(params[:id])
  end

  def download_list
    authorize! :view, :registrant_domains
    params[:q] ||= {}
    domains = current_user.domains
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