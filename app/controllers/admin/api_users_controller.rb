module Admin
  class ApiUsersController < BaseController
    load_and_authorize_resource
    before_action :set_api_user, only: [:show, :edit, :update, :destroy]
    before_action :find_registrar, only: %i[new create]

    def index
      @q = ApiUser.includes(:registrar).search(params[:q])
      @api_users = @q.result.page(params[:page])
    end

    def new
      @api_user = ApiUser.new
    end

    def create
      @api_user = @registrar.api_users.build(api_user_params)

      if @api_user.save
        flash[:notice] = I18n.t('record_created')
        redirect_to [:admin, @api_user]
      else
        flash.now[:alert] = I18n.t('failed_to_create_record')
        render 'new'
      end
    end

    def show;
    end

    def edit;
    end

    def update
      if params[:api_user][:plain_text_password].blank?
        params[:api_user].delete(:plain_text_password)
      end

      if @api_user.update(api_user_params)
        flash[:notice] = I18n.t('record_updated')
        redirect_to [:admin, @api_user]
      else
        flash.now[:alert] = I18n.t('failed_to_update_record')
        render 'edit'
      end
    end

    def destroy
      if @api_user.destroy
        flash[:notice] = I18n.t('record_deleted')
        redirect_to admin_api_users_path
      else
        flash.now[:alert] = I18n.t('failed_to_delete_record')
        render 'show'
      end
    end

    private

    def set_api_user
      @api_user = ApiUser.find(params[:id])
    end

    def api_user_params
      params.require(:api_user).permit(:username, :plain_text_password, :active,
                                       :identity_code, { roles: [] })
    end

    def find_registrar
      @registrar = Registrar.find(params[:registrar_id])
    end
  end
end
