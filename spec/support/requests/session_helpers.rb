module Requests
  module SessionHelpers
    def sign_in_to_admin_area(user: create(:admin_user))
      post admin_user_session_path, admin_user: { username: user.username, password: user.password }
    end

    def sign_in_to_registrar_area(user: create(:api_user))
      post registrar_user_session_path, { registrar_user: { username: user.username, password: user.plain_text_password } }
    end
  end
end