module Requests
  module SessionHelpers
    def sign_in_to_admin_area(user: create(:admin_user))
      post admin_sessions_path, admin_user: { username: user.username, password: user.password }
    end

    def sign_in_to_registrar_area(user: create(:api_user))
      post registrar_sessions_path, { depp_user: { tag: user.username, password: user.password } }
    end
  end
end
