class Registrar
  class CurrentUserController < BaseController
    skip_authorization_check

    def switch
      raise 'Cannot switch to unlinked user' unless current_user.linked_with?(new_user)

      sign_in(new_user)
      redirect_to :back, notice: t('.switched', new_user: new_user)
    end

    private

    def new_user
      @new_user ||= ApiUser.find(params[:new_user_id])
    end
  end
end
