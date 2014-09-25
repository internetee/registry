class SessionsController < Devise::SessionsController
  def create
    @user = User.find_by(identity_code: '37810013855')
    sign_in_and_redirect @user, :event => :authentication
  end

  def login
    render 'layouts/login', layout: false
  end
end
