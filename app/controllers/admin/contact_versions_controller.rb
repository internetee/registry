class Admin::ContactVersionsController < AdminController
  load_and_authorize_resource

  def index
    params[:q] ||= {}
    @q = ContactVersion.search(params[:q])
    @versions = @q.result.page(params[:page])

    versions = ContactVersion.all

    normalize_search_parameters do
      @q = versions.search(params[:q])
      @versions = @q.result.page(params[:page])
    end

    @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i > 0
  end

  def search
    render json: ContactVersion.search_by_query(params[:q])
  end

  def normalize_search_parameters
    ca_cache = params[:q][:created_at_lteq]
    begin
      end_time = params[:q][:created_at_lteq].try(:to_date)
      params[:q][:created_at_lteq] = end_time.try(:end_of_day)
      end_time = params[:q][:updated_at_gteq].try(:to_date)
      params[:q][:updated_at_lteq] = end_time.try(:end_of_day)
    rescue
      logger.warn('Invalid date')
    end

    yield

    params[:q][:created_at_lteq] = ca_cache
  end

end
