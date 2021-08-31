module Admin
  class RegistrarsController < BaseController
    load_and_authorize_resource
    before_action :set_registrar, only: [:show, :edit, :update, :destroy]
    before_action :set_registrar_status_filter, only: [:index]
    helper_method :registry_vat_rate
    helper_method :iban_max_length

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

    private

    def filter_by_status
      case params[:status]
      when 'Active'
        Registrar.includes(:accounts, :api_users).where.not(api_users: { id: nil }).ordered
      when 'Inactive'
        Registrar.includes(:accounts, :api_users).where(api_users: { id: nil }).ordered
      else
        Registrar.includes(:accounts, :api_users).ordered
      end
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
