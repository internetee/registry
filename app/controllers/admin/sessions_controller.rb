module Admin
  class SessionsController < Devise::SessionsController
    def new
      @admin_user = AdminUser.new
    end

    def create
      if params[:admin_user].blank?
        @admin_user = AdminUser.new
        flash[:alert] = 'Something went wrong'
        return render :new
      end

      @admin_user = AdminUser.find_by(username: params[:admin_user][:username])
      @admin_user ||= AdminUser.new(username: params[:admin_user][:username])

      if @admin_user.valid_password?(params[:admin_user][:password])
        sign_in_and_redirect(:admin_user, @admin_user, event: :authentication)
      else
        flash[:alert] = 'Authorization error'
        render :new
      end
    end

    private

    def after_sign_in_path_for(_resource_or_scope)
      admin_root_path
    end

    def after_sign_out_path_for(_resource_or_scope)
      new_admin_user_session_path
    end

    def user_for_paper_trail
      current_admin_user ? current_admin_user.id_role_username : 'guest'
    end
  end
end