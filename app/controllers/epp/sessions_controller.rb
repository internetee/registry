class Epp::SessionsController < ApplicationController
  protect_from_forgery with: :null_session

  def greeting; end

  def proxy
    send(params[:command])
  end

  private
  def login
    render 'login'
  end
end
