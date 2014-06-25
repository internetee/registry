class Epp::ErrorsController < ApplicationController
  include Epp::Common

  def error
    render '/epp/error'
  end
end
