module Epp
  class ErrorsController < BaseController
    skip_authorization_check

    def error
      epp_errors.add(:epp_errors, code: params[:code], msg: params[:msg])
      render_epp_response '/epp/error'
    end

    def command_handler
      epp_errors.add(:epp_errors, code: '2000', msg: 'Unknown command')
      render_epp_response '/epp/error'
    end
  end
end
