module Epp::Common
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :null_session
    before_action :validate_request, only: [:proxy]
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

  def validate_request
    xsd = Nokogiri::XML::Schema(File.read('doc/schemas/epp-1.0.xsd'))
    doc = Nokogiri::XML(params[:frame])
    @extValues = xsd.validate(doc)
    if @extValues.any?
      @code = '2001'
      @msg = 'Command syntax error'
      render '/epp/error' and return
    end
  end
end
