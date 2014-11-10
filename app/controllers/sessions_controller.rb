class SessionsController < Devise::SessionsController
  def create
    # TODO: Create ID Card login here:
    # this is just testing config
    # if Rails.env.development? || Rails.env.test?
    @user = User.find_by(username: 'gitlab') if params[:gitlab]

    session[:current_user_registrar_id] = Registrar.first.id if @user.admin?

    flash[:notice] = I18n.t('shared.welcome')
    sign_in_and_redirect @user, event: :authentication
    # end
  end

  def login
    render 'layouts/login', layout: false
  end

  def switch_registrar
    authorize! :switch, :registrar
    session[:current_user_registrar_id] = params[:registrar_id]
    redirect_to client_root_path
  end
end
