class Registrar
  class CurrentUserController < BaseController
    skip_authorization_check

    def switch
      new_user = ApiUser.find(params[:new_user_id])
      sign_in(new_user) if new_user.identity_code == current_user.identity_code

      redirect_to :back, notice: t('.switched', new_user: new_user)
    end
  end
end
