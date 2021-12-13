require 'net/http'

module Admin
  class RegistrarsController < BaseController  # rubocop:disable Metrics/ClassLength
    load_and_authorize_resource
    before_action :set_registrar, only: [:show, :edit, :update, :destroy]
    before_action :set_registrar_status_filter, only: [:index]
    helper_method :registry_vat_rate
    helper_method :iban_max_length

    SQL_SUM_STR = 'sum(case active when TRUE then 1 else 0 end)'.freeze

    def index
      registrars = filter_by_status
      @q = registrars.ransack(params[:q])
      @registrars = @q.result(distinct: true).page(params[:page])
      @registrars = @registrars.per(params[:results_per_page]) if paginate?
    end

    def new
      @registrar = Registrar.new
    end

    def create
      @registrar = Registrar.new(registrar_params)
      @registrar.reference_no = ::Billing::ReferenceNo.generate

      if @registrar.valid?
        @registrar.transaction do
          @registrar.save!
          @registrar.accounts.create!(account_type: Account::CASH, currency: 'EUR')
        end

        redirect_to [:admin, @registrar], notice: t('.created')
      else
        render :new
      end
    end

    def edit; end

    def update
      if @registrar.update(registrar_params)
        redirect_to [:admin, @registrar], notice: t('.updated')
      else
        render :edit
      end
    end

    def destroy
      if @registrar.destroy
        flash[:notice] = t('.deleted')
        redirect_to admin_registrars_url
      else
        flash[:alert] = @registrar.errors.full_messages.first
        redirect_to admin_registrar_url(@registrar)
      end
    end

    def set_test_date
      registrar = Registrar.find(params[:registrar_id])

      uri = URI.parse((ENV['registry_demo_registrar_results_url'] || 'http://testapi.test') + "?registrar_name=#{registrar.name}")

      response = base_get_request(uri: uri, port: ENV['registry_demo_registrar_port'])

      if response.code == "200"
        return record_result_for_each_api_user(response: response)
      else
        return redirect_to request.referrer, notice: 'Registrar no found'
      end

      redirect_to request.referrer, notice: 'Something goes wrong'
    end

    def remove_test_date
      registrar = Registrar.find(params[:registrar_id])
      registrar.api_users.each do |api|
        api.accreditation_date = nil
        api.accreditation_expire_date = nil
        api.save
      end

      redirect_to request.referrer
    end

    private

    def record_result_for_each_api_user(response:)
      result = JSON.parse(response.body)
      registrar_users = result['registrar_users']

      return redirect_to request.referrer, notice: 'Registrar found, but not accreditated yet' if registrar_users.empty?

      registrar_users.each do |api|
        a = ApiUser.find_by(username: api['username'], identity_code: api['identity_code'])
        Actions::RecordDateOfTest.record_result_to_api_user(api_user: a, date: api['accreditation_date']) unless a.nil?
      end

      redirect_to request.referrer, notice: 'Registrar found'
    end

    def base_get_request(uri:, port:)
      http = Net::HTTP.new(uri.host, port)
      req = Net::HTTP::Get.new(uri.request_uri)

      http.request(req)
    end

    def filter_by_status
      case params[:status]
      when 'Active'
        active_registrars
      when 'Inactive'
        inactive_registrars
      else
        Registrar.includes(:accounts, :api_users).ordered
      end
    end

    def active_registrars
      Registrar.includes(:accounts, :api_users).where(
        id: ApiUser.having("#{SQL_SUM_STR} > 0").group(:registrar_id).pluck(:registrar_id)
      ).ordered
    end

    def inactive_registrars
      Registrar.includes(:accounts, :api_users).where(api_users: { id: nil }).or(
        Registrar.includes(:accounts, :api_users).where(
          id: ApiUser.having("#{SQL_SUM_STR} = 0").group(:registrar_id).pluck(:registrar_id)
        )
      ).ordered
    end

    def set_registrar_status_filter
      params[:status] ||= 'Active'
    end

    def set_registrar
      @registrar = Registrar.find(params[:id])
    end

    def registrar_params
      params.require(:registrar).permit(:name,
                                        :reg_no,
                                        :email,
                                        :address_street,
                                        :address_zip,
                                        :address_city,
                                        :address_state,
                                        :address_country_code,
                                        :phone,
                                        :website,
                                        :code,
                                        :test_registrar,
                                        :vat_no,
                                        :vat_rate,
                                        :accounting_customer_code,
                                        :billing_email,
                                        :legaldoc_optout,
                                        :legaldoc_optout_comment,
                                        :iban,
                                        :language)
    end

    def registry_vat_rate
      Registry.current.vat_rate
    end

    def iban_max_length
      Iban.max_length
    end
  end
end
