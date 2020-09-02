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
        redirect_to admin_registrar_api_user_path(@api_user.registrar, @api_user),
                    notice: t('.created')
      else
        render 'new'
      end
    end

    def show;
    end

    def edit;
    end

    def update
      @api_user.attributes = api_user_params

      if @api_user.valid?
        @api_user.save!
        redirect_to admin_registrar_api_user_path(@api_user.registrar, @api_user),
                    notice: t('.updated')
      else
        render 'edit'
      end
    end

    def destroy
      @api_user.destroy!
      redirect_to admin_registrar_path(@api_user.registrar), notice: t('.deleted')
    end

    private

    def api_user_params
      params.require(:api_user).permit(:username, :plain_text_password, :active,
                                       :identity_code, { roles: [] })
    end

    def registrar
      Registrar.find(params[:registrar_id])
    end
  end
end
