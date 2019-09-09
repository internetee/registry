module Epp
  class ErrorsController < BaseController
    skip_authorization_check

    def error
      epp_errors << { code: params[:code], msg: params[:msg] }
      render_epp_response '/epp/error'
    end

    def not_found
      epp_errors << { code: 2400, msg: t(:could_not_determine_object_type_check_xml_format_and_namespaces) }
      render_epp_response '/epp/error'
    end
  end
end
