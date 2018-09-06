class Registrar
  module Settings
    class AutoAccountTopUpController < BaseController
      before_action :authorize

      def edit
        @registrar = registrar
      end

      def update
        registrar.update!(registrar_params)
        redirect_to registrar_settings_root_url, notice: t('.updated')
      end

      private

      def registrar
        current_registrar_user.registrar
      end

      def registrar_params
        params.require(:registrar).permit(:auto_account_top_up_activated,
                                          :auto_account_top_up_low_balance_threshold,
                                          :auto_account_top_up_amount,
                                          :auto_account_top_up_iban)
      end

      def authorize
        authorize!(:manage, :auto_account_top_up_settings)
      end
    end
  end
end
