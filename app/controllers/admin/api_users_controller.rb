module Admin
  class ApiUsersController < BaseController
    load_and_authorize_resource

    def index
      @q = ApiUser.includes(:registrar).ransack(params[:q])
      @api_users = @q.result.page(params[:page])
      @api_users = @api_users.per(params[:results_per_page]) if paginate?
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

    def set_test_date_to_api_user
      user_api = User.find(params[:user_api_id])
      apiusers_from_test = Actions::GetAccrResultsFromAnotherDb.userapi_from_another_db(user_api: user_api)

      Actions::RecordDateOfTest.record_result_to_api_user(
        user_api,
        apiusers_from_test.accreditation_date) unless apiusers_from_test.nil?

      # redirect_to admin_registrar_api_user_path(user_api.registrar)
      redirect_to admin_registrar_path(user_api.registrar)
    end

    def remove_test_date_to_api_user
      user_api = User.find(params[:user_api_id])
      user_api.accreditation_date = nil
      user_api.accreditation_expire_date = nil
      user_api.save

      redirect_to admin_registrar_path(user_api.registrar)
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
