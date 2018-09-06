class Registrar
  module Settings
    class BalanceAutoReloadController < BaseController
      before_action :authorize

      def edit
        @type = if current_registrar.settings['balance_auto_reload']
                  type_params = current_registrar.settings['balance_auto_reload']['type']
                                                 .except('name')
                  BalanceAutoReloadTypes::Threshold.new(type_params)
                else
                  BalanceAutoReloadTypes::Threshold.new
                end
      end

      def update
        type = BalanceAutoReloadTypes::Threshold.new(type_params)
        current_registrar.update!(settings: { balance_auto_reload: { type: type } })

        redirect_to registrar_account_path, notice: t('.saved')
      end

      def destroy
        current_registrar.settings.delete('balance_auto_reload')
        current_registrar.save!

        redirect_to registrar_account_path, notice: t('.disabled')
      end

      private

      def type_params
        permitted_params = params.require(:type).permit(:amount, :threshold)
        normalize_params(permitted_params)
      end

      def normalize_params(params)
        params[:amount] = params[:amount].to_f
        params[:threshold] = params[:threshold].to_f
        params
      end

      def authorize
        authorize!(:manage, :balance_auto_reload)
      end

      def current_registrar
        current_registrar_user.registrar
      end
    end
  end
end