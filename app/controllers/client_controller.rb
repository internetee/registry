class ClientController < ApplicationController
  def current_user
    EppUser.first
  end
end
