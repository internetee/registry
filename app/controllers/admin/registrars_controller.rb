module Admin
  class RegistrarsController < BaseController
    load_and_authorize_resource
    before_action :set_registrar, only: [:show, :edit, :update, :destroy]

    def search
      render json: Registrar.search_by_query(params[:q])
    end

    def index
      @q = Registrar.joins(:accounts).ordered.search(params[:q])
      @registrars = @q.result.page(params[:page])
    end

    def new
      @registrar = Registrar.new
    end

    def create
      @registrar = Registrar.new(registrar_params)

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

    def edit;
    end

    def update
      if @registrar.update(registrar_params)
        redirect_to [:admin, @registrar], notice: t('.updated')
      else
        render :edit
      end
    end

    def destroy
      @registrar.destroy!
      redirect_to admin_registrars_url, notice: t('.deleted')
    end

    private

    def set_registrar
      @registrar = Registrar.find(params[:id])
    end

    def registrar_params
      params.require(:registrar).permit(:name,
                                        :reg_no,
                                        :street,
                                        :city,
                                        :state,
                                        :zip,
                                        :country_code,
                                        :email,
                                        :phone,
                                        :website,
                                        :billing_email,
                                        :code,
                                        :test_registrar,
                                        :vat_no,
                                        :vat_rate,
                                        :accounting_customer_code,
                                        :billing_email,
                                        :language)
    end
  end
end
