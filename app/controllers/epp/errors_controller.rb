module Epp
  class ErrorsController < BaseController
    skip_authorization_check

    def error
      epp_errors << { code: params[:code], msg: params[:msg] }
      render_epp_response '/epp/error'
    end
  end
end
