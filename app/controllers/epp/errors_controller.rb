class Epp::ErrorsController < ApplicationController
  include Epp::Common

  def error
    @code, @msg = params[:code], params[:msg]
    render '/epp/error'
  end
end
