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

      begin
        @registrar.transaction do
          @registrar.save!
          @registrar.accounts.create!(account_type: Account::CASH, currency: 'EUR')
        end

        flash[:notice] = t('.created')
        redirect_to [:admin, @registrar]
      rescue ActiveRecord::RecordInvalid
        flash.now[:alert] = t('.not_created')
        render 'new'
      end
    end

    def edit;
    end

    def update
      if @registrar.update(registrar_params)
        flash[:notice] = t('.updated')
        redirect_to [:admin, @registrar]
      else
        flash.now[:alert] = t('.not_updated')
        render 'edit'
      end
    end

    def destroy
      if @registrar.destroy
        flash[:notice] = I18n.t('registrar_deleted')
        redirect_to admin_registrars_path
      else
        flash.now[:alert] = I18n.t('failed_to_delete_registrar')
        render 'show'
      end
    end

    private

    def set_registrar
      @registrar = Registrar.find(params[:id])
    end

    def registrar_params
      params.require(:registrar).permit(
        :name, :reg_no, :vat_no, :street, :city, :state, :zip, :billing_address,
        :country_code, :email, :phone, :website, :billing_email, :code, :test_registrar
      )
    end
  end
end
