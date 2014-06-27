module Epp::Common
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :null_session
    helper_method :epp_head
  end

  def proxy
    @svTRID = "ccReg-#{'%010d' % rand(10 ** 10)}"
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

  def epp_head xml
    xml.instruct!
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd') do
      yield
    end
  end

end
