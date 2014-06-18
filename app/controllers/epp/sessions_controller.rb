class Epp::SessionsController < ApplicationController
  def index
    render 'hello'
  end

  def create
    render 'login'
  end
end
