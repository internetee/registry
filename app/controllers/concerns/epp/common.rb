module Epp::Common
  extend ActiveSupport::Concern

  OBJECT_TYPES = {
    'urn:ietf:params:xml:ns:contact-1.0' => 'contact',
    'urn:ietf:params:xml:ns:domain-1.0' => 'domain'
  }

  included do
    protect_from_forgery with: :null_session
    before_action :validate_request, only: [:proxy]
  end

  def proxy
    @svTRID = "ccReg-#{'%010d' % rand(10 ** 10)}"
    send(params[:command])
  end

  def params_hash
    @params_hash ||= Hash.from_xml(params[:frame]).with_indifferent_access
  end

  def epp_session
    EppSession.find_or_initialize_by(session_id: cookies['session'])
  end

  def epp_errors
    @errors ||= []
  end

  def current_epp_user
    @current_epp_user ||= EppUser.find(epp_session[:epp_user_id]) if epp_session[:epp_user_id]
  end

  def handle_epp_errors(error_code_map, obj)
    obj.errors.each do |key, msg|
      if msg.is_a?(Hash)
          epp_errors << {
            code: find_code(msg[:msg]),
            msg: msg[:msg],
            value: {obj: msg[:obj], val: msg[:val]},
          }
      else
        next unless code = find_code(msg)
        epp_errors << {
          code: code,
          msg: msg
        }
      end
    end
  end

  def find_code(msg)
    error_code_map.each do |code, values|
      return code if values.include?(msg)
    end
    nil
  end

  def validate_request
    type = OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]
    return unless type

    xsd = Nokogiri::XML::Schema(File.read("doc/schemas/#{type}-1.0.xsd"))
    doc = Nokogiri::XML(params[:frame])
    ext_values = xsd.validate(doc)
    if ext_values.any?
      epp_errors << {code: '2001', msg: 'Command syntax error', ext_values: ext_values}
      render '/epp/error' and return
    end
  end
end
