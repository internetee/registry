class Registrar
  class AccountController < BaseController
    skip_authorization_check

    def show; end

    def edit
      @registrar = current_registrar_user.registrar
    end

    def update
      @registrar = current_registrar_user.registrar
      @registrar.update!(registrar_params)

      redirect_to registrar_account_path, notice: t('.saved')
    end

    private

    def registrar_params
      params.require(:registrar).permit(:billing_email, :iban)
    end
  end
end