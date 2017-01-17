class Admin::SessionsController < Devise::SessionsController
  skip_authorization_check only: :create

  def login
    @admin_user = AdminUser.new
  end

  def create
    if params[:admin_user].blank?
      @admin_user = AdminUser.new
      flash[:alert] = 'Something went wrong'
      return render 'login'
    end

    @admin_user = AdminUser.find_by(username: params[:admin_user][:username])
    @admin_user ||= AdminUser.new(username: params[:admin_user][:username])

    if @admin_user.valid_password?(params[:admin_user][:password])
      sign_in @admin_user, event: :authentication
      redirect_to admin_root_url, notice: I18n.t(:welcome)
    else
      flash[:alert] = 'Authorization error'
      render 'login'
    end
  end
end
