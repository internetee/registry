class Epp::SessionsController < ApplicationController
  protect_from_forgery with: :null_session

  def proxy
    send(params[:command])
  end

  private
  def hello
    render 'greeting'
  end

  def login
    render 'login'
  end
end
