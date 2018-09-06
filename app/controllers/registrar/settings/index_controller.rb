class Registrar
  module Settings
    class IndexController < BaseController
      skip_authorization_check
      helper_method :show_auto_account_top_up?

      def show
        @registrar = current_registrar_user.registrar
      end

      private

      def show_auto_account_top_up?
        auto_account_top_up_enabled? && authorized_to_edit_auto_account_top_up?
      end

      def authorized_to_edit_auto_account_top_up?
        can?(:manage, :auto_account_top_up_settings)
      end

      def auto_account_top_up_enabled?
        ENV['auto_account_top_up'] == 'true'
      end
    end
  end
end
