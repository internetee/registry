class Admin::EppUsersController < AdminController
  before_action :set_epp_user, only: [:show, :edit, :update, :destroy]

  def index
    @q = EppUser.search(params[:q])
    @epp_users = @q.result.page(params[:page])
  end

  def new
    @epp_user = EppUser.new
  end

  def create
    @epp_user = EppUser.new(epp_user_params)

    if @epp_user.save
      flash[:notice] = I18n.t('shared.record_created')
      redirect_to [:admin, @epp_user]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_create_record')
      render 'new'
    end
  end

  def show; end

  def edit; end

  def update
    if @epp_user.update(epp_user_params)
      flash[:notice] = I18n.t('shared.record_updated')
      redirect_to [:admin, @epp_user]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_update_record')
      render 'edit'
    end
  end

  def destroy
    if @epp_user.destroy
      flash[:notice] = I18n.t('shared.record_deleted')
      redirect_to admin_epp_users_path
    else
      flash.now[:alert] = I18n.t('shared.failed_to_delete_record')
      render 'show'
    end
  end

  private

  def set_epp_user
    @epp_user = EppUser.find(params[:id])
  end

  def epp_user_params
    params.require(:epp_user).permit(:username, :password, :crt, :active, :registrar_id, :registrar_typeahead)
  end
end
