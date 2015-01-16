module Epp::Common
  extend ActiveSupport::Concern

  OBJECT_TYPES = {
    'urn:ietf:params:xml:ns:contact-1.0' => 'contact',
    'urn:ietf:params:xml:ns:domain-1.0' => 'domain'
  }

  included do
    protect_from_forgery with: :null_session
    before_action :validate_request
    layout false
    helper_method :current_epp_user
  end

  def proxy
    # rubocop: disable Style/VariableName
    @svTRID = "ccReg-#{format('%010d', rand(10**10))}"
    # rubocop: enable Style/VariableName
    send(params[:command])
  end

  def params_hash
    @params_hash ||= Hash.from_xml(params[:frame]).with_indifferent_access
  end

  def parsed_frame
    @parsed_frame ||= Nokogiri::XML(params[:frame]).remove_namespaces!
  end

  def epp_session
    cookie = env['rack.request.cookie_hash'] || {}
    EppSession.find_or_initialize_by(session_id: cookie['session'])
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
      obj.construct_epp_errors
      @errors += obj.errors[:epp_errors]
    end

    # for debugging
    @errors << {
      code: '1',
      msg: 'handle_errors was executed when there were actually no errors'
    } if @errors.blank?

    @errors.uniq!

    render_epp_response '/epp/error'
  end

  def append_errors(obj)
    obj.construct_epp_errors
    @errors += obj.errors[:epp_errors]
  end

  def epp_request_valid?(*selectors)
    selectors.each do |selector|
      el = parsed_frame.css(selector).first
      epp_errors << {
        code: '2003',
        msg: I18n.t('errors.messages.required_parameter_missing', key: el.try(:name) || selector)
      } if el.nil? || el.text.blank?
    end

    epp_errors.empty?
  end

  def xml_attrs_present?(ph, attributes)
    attributes.each do |x|
      epp_errors << {
        code: '2003',
        msg: I18n.t('errors.messages.required_parameter_missing', key: x.last)
      } unless has_attribute(ph, x)
    end
    epp_errors.empty?
  end

  def xml_attrs_array_present?(array_ph, attributes)
    [array_ph].flatten.each do |ph|
      attributes.each do |x|
        next if has_attribute(ph, x)
        epp_errors << {
          code: '2003',
          msg: I18n.t('errors.messages.required_parameter_missing', key: x.last)
        }
      end
    end
    epp_errors.empty?
  end

  # rubocop: disable Style/PredicateName
  def has_attribute(ph, path)
    path.reduce(ph) do |location, key|
      location.respond_to?(:keys) ? location[key] : nil
    end
  end
  # rubocop: enable Style/PredicateName

  def validate_request
    validation_method = "validate_#{params[:action]}"
    return unless respond_to?(validation_method, true)
    handle_errors and return unless send(validation_method)
  end

  def render_epp_response(*args)
    @response = render_to_string(*args)
    render xml: @response
    write_to_epp_log
  end

  def write_to_epp_log
    request_command = params[:command] || params[:action] # error receives :command, other methods receive :action
    ApiLog::EppLog.create({
      request: params[:raw_frame] || params[:frame],
      request_command: request_command,
      request_successful: epp_errors.empty?,
      request_object: params[:epp_object_type], # TODO: fix this for login and logout
      response: @response,
      api_user_name: @epp_user.try(:to_s) || current_epp_user.try(:to_s),
      api_user_registrar: @epp_user.try(:registrar).try(:to_s) || current_epp_user.try(:registrar).try(:to_s),
      ip: request.ip
    })
  end
end
