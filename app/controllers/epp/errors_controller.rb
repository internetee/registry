class Epp::ErrorsController < ApplicationController
  include Epp::Common
  layout false

  def error
    epp_errors << { code: params[:code], msg: params[:msg] }
    render '/epp/error'
  end
end
