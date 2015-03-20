class Registrar::SessionsController < SessionsController
  layout 'registrar'

  def create
    @user = ApiUser.first if params[:user1]

    return redirect_to :back, alert: 'No user' if @user.blank?

    flash[:notice] = I18n.t('welcome')
    sign_in_and_redirect @user, event: :authentication
  end

  def login

  end
end
