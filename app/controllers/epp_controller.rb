class EppController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :generate_svtrid
  before_action :validate_request
  layout false
  helper_method :current_epp_user

  def generate_svtrid
    # rubocop: disable Style/VariableName
    @svTRID = "ccReg-#{format('%010d', rand(10**10))}"
    # rubocop: enable Style/VariableName
  end

  def params_hash # TODO: THIS IS DEPRECATED AND WILL BE REMOVED IN FUTURE
    @params_hash ||= Hash.from_xml(params[:frame]).with_indifferent_access
  end

  # SESSION MANAGEMENT
  def epp_session
    cookie = env['rack.request.cookie_hash'] || {}
    EppSession.find_or_initialize_by(session_id: cookie['session'])
  end

  def current_epp_user
    @current_epp_user ||= EppUser.find(epp_session[:epp_user_id]) if epp_session[:epp_user_id]
  end

  # ERROR + RESPONSE HANDLING
  def epp_errors
    @errors ||= []
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

  def render_epp_response(*args)
    @response = render_to_string(*args)
    render xml: @response
    write_to_epp_log
  end

  # VALIDATION
  def validate_request
    validation_method = "validate_#{params[:action]}"
    return unless respond_to?(validation_method, true)
    send(validation_method)

    # validate legal document's type here because it may be in most of the requests
    @prefix = nil
    if element_count('extension > extdata > legalDocument') > 0
      requires_attribute('extension > extdata > legalDocument', 'type', values: LegalDocument::TYPES)
    end

    handle_errors and return if epp_errors.any?
  end

  # let's follow grape's validations: https://github.com/intridea/grape/#parameter-validation-and-coercion

  # Adds error to epp_errors if element is missing or blank
  # Returns last element of selectors if it exists
  #
  #    requires 'transfer'
  #
  # TODO: Add possibility to pass validations / options in the method

  def requires(*selectors)
    el, missing = nil, nil
    selectors.each do |selector|
      full_selector = [@prefix, selector].compact.join(' ')
      el = params[:parsed_frame].css(full_selector).first

      missing = el.nil?
      epp_errors << {
        code: '2003',
        msg: I18n.t('errors.messages.required_parameter_missing', key: full_selector)
      } if missing
    end

    missing ? false : el # return last selector if it was present
  end

  # Adds error to epp_errors if element or attribute is missing or attribute attribute is not one
  # of the values
  #
  # requires_attribute 'transfer', 'op', values: %(approve, query, reject)

  def requires_attribute(element_selector, attribute_selector, options)
    element = requires(element_selector)
    return unless element

    attribute = element[attribute_selector]

    return if attribute && options[:values].include?(attribute)

    epp_errors << {
      code: '2306',
      msg: I18n.t('attribute_is_invalid', attribute: attribute_selector)
    }
  end

  def exactly_one_of(*selectors)
    full_selectors = create_full_selectors(*selectors)
    return if element_count(*full_selectors, use_prefix: false) == 1

    epp_errors << {
      code: '2306',
      msg: I18n.t(:exactly_one_parameter_required, params: full_selectors.join(' OR '))
    }
  end

  def mutually_exclusive(*selectors)
    full_selectors = create_full_selectors(*selectors)
    return if element_count(*full_selectors, use_prefix: false) <= 1

    epp_errors << {
      code: '2306',
      msg: I18n.t(:mutally_exclusive_params, params: full_selectors.join(', '))
    }
  end

  def optional(selector, *validations)
    full_selector = [@prefix, selector].compact.join(' ')
    el = params[:parsed_frame].css(full_selector).first
    return unless el && el.text.present?
    value = el.text

    validations.each do |x|
      validator = "#{x.first[0]}_validator".camelize.constantize
      err = validator.validate_epp(selector.split(' ').last, value)
      epp_errors << err if err
    end
  end

  # Returns how many elements were present in the request
  # if use_prefix is true, @prefix will be prepended to selectors e.g create > create > name
  # default is true
  #
  # @prefix = 'create > create >'
  # element_count 'name', 'registrar', use_prefix: false
  # => 2

  def element_count(*selectors)
    options = selectors.extract_options!
    use_prefix = options[:use_prefix] != false # use_prefix is true by default

    present_count = 0
    selectors.each do |selector|
      full_selector = use_prefix ? [@prefix, selector].compact.join(' ') : selector
      el = params[:parsed_frame].css(full_selector).first
      present_count += 1 if el && el.text.present?
    end
    present_count
  end

  def create_full_selectors(*selectors)
    selectors.map { |x| [@prefix, x].compact.join(' ') }
  end

  def xml_attrs_present?(ph, attributes) # TODO: THIS IS DEPRECATED AND WILL BE REMOVED IN FUTURE
    attributes.each do |x|
      epp_errors << {
        code: '2003',
        msg: I18n.t('errors.messages.required_parameter_missing', key: x.last)
      } unless has_attribute(ph, x)
    end
    epp_errors.empty?
  end

  # rubocop: disable Style/PredicateName
  def has_attribute(ph, path) # TODO: THIS IS DEPRECATED AND WILL BE REMOVED IN FUTURE
    path.reduce(ph) do |location, key|
      location.respond_to?(:keys) ? location[key] : nil
    end
  end
  # rubocop: enable Style/PredicateName

  def write_to_epp_log
    # return nil if EPP_LOG_ENABLED
    request_command = params[:command] || params[:action] # error receives :command, other methods receive :action
    ApiLog::EppLog.create({
      request: params[:raw_frame] || params[:frame],
      request_command: request_command,
      request_successful: epp_errors.empty?,
      request_object: params[:epp_object_type],
      response: @response,
      api_user_name: @epp_user.try(:to_s) || current_epp_user.try(:to_s),
      api_user_registrar: @epp_user.try(:registrar).try(:to_s) || current_epp_user.try(:registrar).try(:to_s),
      ip: request.ip
    })
  end
end
