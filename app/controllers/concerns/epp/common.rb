module Epp::Common
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :null_session
  end

  def proxy
    send(params[:command])
  end

  def parsed_frame
    Nokogiri::XML(params[:frame]).remove_namespaces!
  end

  def epp_session
    EppSession.find_or_initialize_by(session_id: cookies['session'])
  end

  def current_epp_user
    @current_epp_user ||= EppUser.find(epp_session[:epp_user_id]) if epp_session[:epp_user_id]
  end
end
