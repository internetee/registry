class Admin::DomainVersionsController < AdminController
  def index
    @q = DomainVersion.deleted.search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  def show
    @versions = DomainVersion.where(item_id: params[:id])
    @name = @versions.last.name
  end
end
