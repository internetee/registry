module Admin
  class ApiUsersController < BaseController
    load_and_authorize_resource

    def index
      @q = ApiUser.includes(:registrar).search(params[:q])
      @api_users = @q.result.page(params[:page])
    end

    def new
      @api_user = registrar.api_users.build
    end

    def create
      @api_user = registrar.api_users.build(api_user_params)

      if @api_user.valid?
        @api_user.save!
        flash[:notice] = I18n.t('record_created')
        redirect_to admin_registrar_api_user_path(@api_user.registrar, @api_user)
      else
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

      @api_user.attributes = api_user_params

      if @api_user.valid?
        @api_user.save!
        flash[:notice] = I18n.t('record_updated')
        redirect_to admin_registrar_api_user_path(@api_user.registrar, @api_user)
      else
        render 'edit'
      end
    end

    def destroy
      @api_user.destroy!
      redirect_to admin_registrar_path(@api_user.registrar), notice: t('record_deleted')
    end

    private

    def set_api_user
      @api_user = ApiUser.find(params[:id])
    end

    def api_user_params
      params.require(:api_user).permit(:username, :plain_text_password, :active,
                                       :identity_code, { roles: [] })
    end

    def registrar
      Registrar.find(params[:registrar_id])
    end
  end
end
