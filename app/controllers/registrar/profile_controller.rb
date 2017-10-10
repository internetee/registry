class Registrar
  class ProfileController < BaseController
    skip_authorization_check

    helper_method :linked_users

    def show
      @user = current_user
    end

    private

    def linked_users
      current_user.linked_users
    end
  end
end
