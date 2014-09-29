class Admin::RegistrarsController < AdminController
  before_action :set_registrar, only: [:show, :edit, :update, :destroy]
  def search
    render json: Registrar.search_by_query(params[:q])
  end

  def index
    @q = Registrar.search(params[:q])
    @registrars = @q.result.page(params[:page])
  end

  def new
    @registrar = Registrar.new
  end

  def create
    @registrar = Registrar.new(registrar_params)

    if @registrar.save
      flash[:notice] = I18n.t('shared.registrar_added')
      redirect_to [:admin, @registrar]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_add_registrar')
      render 'new'
    end
  end

  def edit; end

  def update
    if @registrar.update(registrar_params)
      flash[:notice] = I18n.t('shared.registrar_updated')
      redirect_to [:admin, @registrar]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_update_registrar')
      render 'edit'
    end
  end

  def destroy
    if @registrar.destroy
      flash[:notice] = I18n.t('shared.registrar_deleted')
      redirect_to admin_registrars_path
    else
      flash.now[:alert] = I18n.t('shared.failed_to_delete_registrar')
      render 'show'
    end
  end

  private

  def set_registrar
    @registrar = Registrar.find(params[:id])
  end

  def registrar_params
    params.require(:registrar).permit(:name, :reg_no, :vat_no, :address, :billing_address, :country_id)
  end
end
