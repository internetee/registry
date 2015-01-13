class Epp::ErrorsController < ApplicationController
  include Epp::Common
  layout false

  def error
    epp_errors << { code: params[:code], msg: params[:msg] }
    render_epp_response '/epp/error'
  end
end
