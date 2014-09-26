class SessionsController < Devise::SessionsController
  def create
    #TODO: Create ID Card login here:
    # this is just testing config
    # if Rails.env.development? || Rails.env.test?
    @user = User.find_by(username: 'gitlab') if params[:gitlab]
    @user = User.find_by(username: 'zone') if params[:zone]

    flash[:notice] = I18n.t('shared.welcome')
    sign_in_and_redirect @user, :event => :authentication
    return
    # end
  end

  def login
    render 'layouts/login', layout: false
  end
end
