class Admin::SessionsController < Devise::SessionsController
  skip_authorization_check only: :create
  layout 'admin/application'

  def login
  end

  # def create
    # @user = AdminUser.first if params[:user1]
    # @user = AdminUser.second if params[:user2]

    # return redirect_to :back, alert: 'No user' if @user.blank?

    # flash[:notice] = I18n.t('welcome')
    # sign_in_and_redirect @user, event: :authentication
  # end
end
