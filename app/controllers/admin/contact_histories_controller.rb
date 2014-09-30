class Admin::ContactHistoriesController < AdminController
  def index
    @q = ContactVersion.deleted.search(params[:q])
    @contacts = @q.result.page(params[:page])
  end
end
