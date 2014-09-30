class Admin::DomainHistoriesController < AdminController
  def index
    @q = DomainVersion.deleted.search(params[:q])
    @domains = @q.result.page(params[:page])
  end
end
