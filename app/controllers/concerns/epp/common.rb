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
    node_set = parsed_frame.css(path).children.select{ |x| x.element? && x.element_children.empty? }

    node_set.inject({}) do |hash, obj|
      #convert to array if 1 or more attributes with same name
      if hash[obj.name.to_sym] && !hash[obj.name.to_sym].is_a?(Array)
        hash[obj.name.to_sym] = [hash[obj.name.to_sym]]
        hash[obj.name.to_sym] << obj.text.strip
      else
        hash[obj.name.to_sym] = obj.text.strip
      end

      hash
    end
  end

  def epp_session
    EppSession.find_or_initialize_by(session_id: cookies['session'])
  end

  def current_epp_user
    @current_epp_user ||= EppUser.find(epp_session[:epp_user_id]) if epp_session[:epp_user_id]
  end
end
