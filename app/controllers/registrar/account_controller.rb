class Registrar
  class AccountController < BaseController
    skip_authorization_check
    helper_method :iban_max_length
    helper_method :balance_auto_reload_setting

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

    def iban_max_length
      Iban.max_length
    end

    def balance_auto_reload_setting
      current_registrar_user.registrar.settings['balance_auto_reload']
    end
  end
end