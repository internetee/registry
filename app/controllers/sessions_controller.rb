class SessionsController < Devise::SessionsController
  def create
    # TODO: Create ID Card login here:
    # this is just testing config
    # if Rails.env.development? || Rails.env.test?
    @user = User.first if params[:user1]
    @user = User.second if params[:user2]

    return redirect_to :back, alert: 'No user' if @user.blank?

    flash[:notice] = I18n.t('shared.welcome')
    sign_in_and_redirect @user, event: :authentication
    # end
  end

  def login
    render 'layouts/login', layout: false
  end
end
