class Admin::KeyrelaysController < AdminController
  load_and_authorize_resource

  def index
    @q = Keyrelay.includes(:requester, :accepter).search(params[:q])
    @keyrelays = @q.result.page(params[:page])
  end

  def show; end
end
