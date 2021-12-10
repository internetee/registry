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

      uri = URI.parse(ENV['registry_demo_registrar_api_user_url'] + "?username=#{user_api.username}&identity_code=#{user_api.identity_code}")

      response = base_get_request(uri: uri, port: ENV['registry_demo_registrar_port'])

      if response.code == "200"
        result = JSON.parse(response.body)
        demo_user_api = result['user_api']

        Actions::RecordDateOfTest.record_result_to_api_user(
                                  api_user:user_api,
                                  date: demo_user_api['accreditation_date']) unless demo_user_api.empty?
        return redirect_to request.referrer, notice: 'User Api found'
      else
        return redirect_to request.referrer, notice: 'User Api no found or not accriditated yet'
      end

      redirect_to request.referrer, notice: 'Something goes wrong'
    end

    def remove_test_date_to_api_user
      user_api = User.find(params[:user_api_id])
      user_api.accreditation_date = nil
      user_api.accreditation_expire_date = nil
      user_api.save
      
      redirect_to request.referrer
    end

    private

    def base_get_request(uri:, port:)
      http = Net::HTTP.new(uri.host, port)
      req = Net::HTTP::Get.new(uri.request_uri)

      http.request(req)
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
