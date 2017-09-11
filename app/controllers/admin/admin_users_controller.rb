module Admin
  class AdminUsersController < BaseController
    load_and_authorize_resource
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @q = AdminUser.search(params[:q])
      @admin_users = @q.result.page(params[:page]).order(:username)
    end

    def new
      @admin_user = AdminUser.new
    end

    def show;
    end

    def edit;
    end

    def create
      @admin_user = AdminUser.new(admin_user_params)

      if @admin_user.save
        flash[:notice] = I18n.t('record_created')
        redirect_to [:admin, @admin_user]
      else
        flash.now[:alert] = I18n.t('failed_to_create_record')
        render 'new'
      end
    end

    def update
      params[:admin_user].delete(:password) if params[:admin_user][:password].blank?
      params[:admin_user].delete(:password_confirmation) if params[:admin_user][:password_confirmation].blank?

      if @admin_user.update_attributes(admin_user_params)
        flash[:notice] = I18n.t('record_updated')
        redirect_to [:admin, @admin_user]
      else
        flash.now[:alert] = I18n.t('failed_to_update_record')
        render 'edit'
      end
    end

    def destroy
      if @admin_user.destroy
        flash[:notice] = I18n.t('record_deleted')
        redirect_to admin_admin_users_path
      else
        flash.now[:alert] = I18n.t('failed_to_delete_record')
        render 'show'
      end
    end

    private

    def set_user
      @admin_user = AdminUser.find(params[:id])
    end

    def admin_user_params
      params.require(:admin_user).permit(:username,
                                         :password, :password_confirmation, :identity_code, :email, :country_code, { roles: [] })
    end
  end
end
