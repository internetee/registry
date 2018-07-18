module Admin
  class SessionsController < Devise::SessionsController
    private

    def after_sign_in_path_for(_resource_or_scope)
      admin_root_path
    end

    def after_sign_out_path_for(_resource_or_scope)
      new_admin_user_session_path
    end

    def user_for_paper_trail
      current_admin_user ? current_admin_user.id_role_username : 'anonymous'
    end
  end
end