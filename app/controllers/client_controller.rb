class ClientController < ApplicationController
  def current_user
    EppUser.last
  end
end
