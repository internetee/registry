class Client::DomainsController < ClientController
  def index
    @q = current_user.registrar.domains.search(params[:q])
    @domains = @q.result.page(params[:page])
    render 'admin/domains/index'
  end
end
