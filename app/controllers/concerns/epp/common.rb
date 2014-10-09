module Epp::Common
  extend ActiveSupport::Concern

  OBJECT_TYPES = {
    'urn:ietf:params:xml:ns:contact-1.0' => 'contact',
    'urn:ietf:params:xml:ns:domain-1.0' => 'domain'
  }

  included do
    protect_from_forgery with: :null_session
    before_action :validate_request, only: [:proxy]

    helper_method :current_epp_user
  end

  def proxy
    @svTRID = "ccReg-#{'%010d' % rand(10**10)}"
    send(params[:command])
  end

  def params_hash
    @params_hash ||= Hash.from_xml(params[:frame]).with_indifferent_access
  end

  def parsed_frame
    @parsed_frame ||= Nokogiri::XML(params[:frame]).remove_namespaces!
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

  def handle_errors(obj = nil)
    @errors ||= []
    if obj
      obj.generate_epp_errors
      @errors += obj.errors[:epp_errors]
    end

    # for debugging
    @errors << { code: '1', msg: 'handle_errors was executed when there were actually no errors' } if @errors.blank?

    @errors.uniq!

    render '/epp/error'
  end

  def append_errors(obj)
    obj.construct_epp_errors
    @errors += obj.errors[:epp_errors]
  end

  def xml_attrs_present?(ph, attributes)
    attributes.each do |x|
      epp_errors << { code: '2003', msg: I18n.t('errors.messages.required_parameter_missing', key: x.last) } unless has_attribute(ph, x)
    end
    epp_errors.empty?
  end

  def xml_attrs_array_present?(array_ph, attributes)
    [array_ph].flatten.each do |ph|
      attributes.each do |x|
        unless has_attribute(ph, x)
          epp_errors << { code: '2003', msg: I18n.t('errors.messages.required_parameter_missing', key: x.last) }
        end
      end
    end
    epp_errors.empty?
  end

  def has_attribute(ph, path)
    path.reduce(ph) do |location, key|
      location.respond_to?(:keys) ? location[key] : nil
    end
  end

  def validate_request
    validation_method = "validate_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}_#{params[:command]}_request"
    if respond_to?(validation_method, true)
      handle_errors and return unless send(validation_method)
    end
  end
end
