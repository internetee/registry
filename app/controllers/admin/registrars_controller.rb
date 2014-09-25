class Admin::RegistrarsController < AdminController
  def search
    render json: Registrar.search_by_query(params[:q])
  end

  def index
    @q = Registrar.search(params[:q])
    @registrars = @q.result.page(params[:page])
  end
end
