module Depp
  class KeyrelaysController < ApplicationController
    def show; end

    def create
      keyrelay = Depp::Keyrelay.new(current_user: depp_current_user)
      @data = keyrelay.keyrelay(params)

      if response_ok?
        flash[:epp_results] = [{ 'code' => '1000', 'msg' => 'Command completed successfully' }]
        redirect_to keyrelay_path
      else
        render 'show'
      end
    end
  end
end
