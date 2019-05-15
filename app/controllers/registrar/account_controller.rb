class Registrar
  class AccountController < BaseController
    skip_authorization_check

    helper_method :linked_users

    def show
      @user = current_registrar_user
    end

    private

    def linked_users
      current_registrar_user.linked_users
    end
  end
end
