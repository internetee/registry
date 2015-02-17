class SessionsController < Devise::SessionsController
  skip_authorization_check only: [:login, :create]

  def create
    # TODO: Create ID Card login here:
    # this is just testing config
    # if Rails.env.development? || Rails.env.test?
    @user = AdminUser.first if params[:user1]
    @user = AdminUser.second if params[:user2]

    return redirect_to :back, alert: 'No user' if @user.blank?

    flash[:notice] = I18n.t('welcome')
    sign_in_and_redirect @user, event: :authentication
    # end
  end

  def login
    render 'layouts/login', layout: false
  end
end
