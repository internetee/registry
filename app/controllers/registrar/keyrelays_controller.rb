class Registrar
  class KeyrelaysController < DeppController
    def show
      authorize! :view, Depp::Keyrelay
    end

    def create
      authorize! :create, Depp::Keyrelay
      keyrelay = Depp::Keyrelay.new(current_user: depp_current_user)
      @data = keyrelay.keyrelay(params)

      if response_ok?
        flash[:epp_results] = [{ 'code' => '1000', 'msg' => 'Command completed successfully', 'show' => true }]
        redirect_to registrar_keyrelay_path
      else
        render 'show'
      end
    end
  end
end
