class Admin::ReservedDomainsController < AdminController
  load_and_authorize_resource

  def index

    params[:q] ||= {}
    domains = ReservedDomain.all
    @q = domains.search(params[:q])
    @domains = @q.result.page(params[:page])
    @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i > 0

  end

  def new
    @domain = ReservedDomain.new
  end

  def edit
    authorize! :update, ReservedDomain
  end

  def delete
    authorize! :delete, ReservedDomain
  end
end
