class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @q = User.search(params[:q])
    @users = @q.result.page(params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:notice] = I18n.t('shared.record_created')
      redirect_to [:admin, @user]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_create_record')
      render 'new'
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:notice] = I18n.t('shared.record_updated')
      redirect_to [:admin, @user]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_update_record')
      render 'edit'
    end
  end

  def destroy
    if @user.destroy
      flash[:notice] = I18n.t('shared.record_deleted')
      redirect_to admin_users_path
    else
      flash.now[:alert] = I18n.t('shared.failed_to_delete_record')
      render 'show'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :password, :identity_code, :email, :registrar_id, :admin, :registrar_typeahead, :country_id)
  end
end
