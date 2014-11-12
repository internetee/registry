class Admin::DomainVersionsController < AdminController
  def index
    @q = DomainVersion.deleted.search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  def show
    # @q = DomainVersion.search(item_id_eq: params[:id])
    @versions = DomainVersion.where(item_id: params[:id])
    @name = @versions.last.reify.try(:name) if @versions
  end
end
