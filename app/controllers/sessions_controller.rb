class SessionsController < Devise::SessionsController
  def create
    if Rails.env.development?
      @user = User.find_by(username: 'gitlab') if params[:gitlab]
      @user = User.find_by(username: 'zone') if params[:zone]
      sign_in_and_redirect @user, :event => :authentication
      return
    end
  end

  def login
    render 'layouts/login', layout: false
  end
end
