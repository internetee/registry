module Epp::Common
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :null_session
  end

  def proxy
    @svTRID = "ccReg-#{'%010d' % rand(10 ** 10)}"
    send(params[:command])
  end

  def parsed_frame
    Nokogiri::XML(params[:frame]).remove_namespaces!
  end

  def get_params_hash(path)
    Hash.from_xml(parsed_frame.css(path).to_xml).with_indifferent_access
  end

  def epp_session
    EppSession.find_or_initialize_by(session_id: cookies['session'])
  end

  def current_epp_user
    @current_epp_user ||= EppUser.find(epp_session[:epp_user_id]) if epp_session[:epp_user_id]
  end
end
