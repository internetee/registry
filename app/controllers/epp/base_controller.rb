module Epp
  class BaseController < ActionController::Base
    class AuthorizationError < StandardError; end

    check_authorization
    layout false

    before_action :ensure_session_id_passed
    before_action :generate_svtrid
    before_action :latin_only
    before_action :validate_against_schema
    before_action :validate_request
    before_action :update_epp_session, if: -> { signed_in? }
    before_action :set_current_user_whodunnit

    around_action :wrap_exceptions

    helper_method :current_user
    helper_method :resource

    rescue_from StandardError, with: :respond_with_command_failed_error
    rescue_from AuthorizationError, with: :respond_with_authorization_error
    rescue_from ActiveRecord::RecordNotFound, with: :respond_with_object_does_not_exist_error

    protected

    def respond_with_command_failed_error(exception)
      epp_errors << {
        code: '2400',
        msg: 'Command failed',
      }
      handle_errors
      log_exception(exception)
    end

    def respond_with_object_does_not_exist_error
      epp_errors << {
        code: '2303',
        msg: 'Object does not exist',
      }
      handle_errors
    end

    def respond_with_authorization_error
      epp_errors << {
        code: '2201',
        msg: 'Authorization error',
      }
      handle_errors
    end

    private

    def set_current_user_whodunnit
      User.whodunnit = current_user&.id_role_username
    end

    def wrap_exceptions
      yield
    rescue CanCan::AccessDenied
      raise AuthorizationError
    end

    def validate_against_schema
      return if %w[hello error].include?(params[:action])
      schema.validate(params[:nokogiri_frame]).each do |error|
        epp_errors << {
          code: 2001,
          msg: error
        }
      end
      handle_errors and return if epp_errors.any?
    end

    def schema
      EPP_ALL_SCHEMA
    end

    def generate_svtrid
      @svTRID = "ccReg-#{format('%010d', rand(10 ** 10))}"
    end

    def params_hash # TODO: THIS IS DEPRECATED AND WILL BE REMOVED IN FUTURE
      @params_hash ||= Hash.from_xml(params[:frame]).with_indifferent_access
    end

    def epp_session
      EppSession.find_by(session_id: epp_session_id)
    end

    def current_user
      return unless signed_in?
      epp_session.user
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

      if params[:parsed_frame].at_css('update')
        @errors.each_with_index do |errors, index|
          if errors[:code] == '2304' &&
            errors[:value].present? &&
            errors[:value][:val] == DomainStatus::SERVER_DELETE_PROHIBITED &&
            errors[:value][:obj] == 'status'
            @errors[index][:value][:val] = DomainStatus::PENDING_UPDATE
          end
        end
      end

      @errors.uniq!

      render_epp_response '/epp/error'
    end

    def render_epp_response(*args)
      @response = render_to_string(*args, formats: 'xml')
      render xml: @response
      write_to_epp_log
    end

    # VALIDATION
    def latin_only
      return true if params['frame'].blank?
      if params['frame'].match?(/\A[\p{Latin}\p{Z}\p{P}\p{S}\p{Cc}\p{Cf}\w_\'\+\-\.\(\)\/]*\Z/i)
        return true
      end

      epp_errors << {
        msg: 'Parameter value policy error. Allowed only Latin characters.',
        code: '2306'
      }

      handle_errors and return false
    end

    # VALIDATION
    def validate_request
      validation_method = "validate_#{params[:action]}"
      return unless respond_to?(validation_method, true)
      send(validation_method)

      # validate legal document's type here because it may be in most of the requests
      @prefix = nil
      if element_count('extdata > legalDocument').positive?
        requires_attribute('extdata > legalDocument', 'type', values: LegalDocument::TYPES, policy: true)
      end

      handle_errors and return if epp_errors.any?
    end

    # let's follow grape's validations: https://github.com/intridea/grape/#parameter-validation-and-coercion

    # Adds error to epp_errors if element is missing or blank
    # Returns last element of selectors if it exists
    #
    # requires 'transfer'
    #
    # TODO: Add possibility to pass validations / options in the method

    def requires(*selectors)
      options = selectors.extract_options!
      allow_blank = options[:allow_blank] ||= false # allow_blank is false by default

      el, missing = nil, nil
      selectors.each do |selector|
        full_selector = [@prefix, selector].compact.join(' ')
        attr = selector.split('>').last.strip.underscore
        el = params[:parsed_frame].css(full_selector).first

        if allow_blank
          missing = el.nil?
        else
          missing = el.present? ? el.text.blank? : true
        end
        epp_errors << {
          code: '2003',
          msg: I18n.t('errors.messages.required_parameter_missing', key: "#{full_selector} [#{attr}]")
        } if missing
      end

      missing ? false : el # return last selector if it was present
    end

    # Adds error to epp_errors if element or attribute is missing or attribute attribute is not one
    # of the values
    #
    # requires_attribute 'transfer', 'op', values: %(approve, query, reject)

    def requires_attribute(element_selector, attribute_selector, options)
      element = requires(element_selector, allow_blank: options[:allow_blank])
      return unless element

      attribute = element[attribute_selector]

      unless attribute
        epp_errors << {
          code: '2003',
          msg: I18n.t('errors.messages.required_parameter_missing', key: attribute_selector)
        }
        return
      end

      return if options[:values].include?(attribute)

      if options[:policy]
        epp_errors << {
          code: '2306',
          msg: I18n.t('attribute_is_invalid', attribute: attribute_selector)
        }
      else
        epp_errors << {
          code: '2004',
          msg: I18n.t('parameter_value_range_error', key: attribute_selector)
        }
      end
    end

    def optional_attribute(element_selector, attribute_selector, options)
      full_selector = [@prefix, element_selector].compact.join(' ')
      element = params[:parsed_frame].css(full_selector).first
      return unless element

      attribute = element[attribute_selector]
      return if (attribute && options[:values].include?(attribute)) || !attribute

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
      return unless el&.text.present?
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

    def has_attribute(ph, path) # TODO: THIS IS DEPRECATED AND WILL BE REMOVED IN FUTURE
      path.reduce(ph) do |location, key|
        location.respond_to?(:keys) ? location[key] : nil
      end
    end

    def write_to_epp_log
      request_command = params[:command] || params[:action] # error receives :command, other methods receive :action
      frame = params[:raw_frame] || params[:frame]

      # filter pw
      if request_command == 'login' && frame.present?
        frame.gsub!(/pw>.+<\//, 'pw>[FILTERED]</')
      end
      trimmed_request = frame.gsub(/<eis:legalDocument([^>]+)>([^<])+<\/eis:legalDocument>/, "<eis:legalDocument>[FILTERED]</eis:legalDocument>") if frame.present?

      ApiLog::EppLog.create({
                              request: trimmed_request,
                              request_command: request_command,
                              request_successful: epp_errors.empty?,
                              request_object: resource ? "#{params[:epp_object_type]}: #{resource.class} - #{resource.id} - #{resource.name}" : params[:epp_object_type],
                              response: @response,
                              api_user_name: @api_user.try(:username) || current_user.try(:username) || 'api-public',
                              api_user_registrar: @api_user.try(:registrar).try(:to_s) || current_user.try(:registrar).try(:to_s),
                              ip: request.ip,
                              uuid: request.uuid
                            })
    end

    def resource
      name = self.class.to_s.sub("Epp::", "").sub("Controller", "").underscore.singularize
      instance_variable_get("@#{name}")
    end

    def signed_in?
      epp_session
    end

    def epp_session_id
      cookies[:session] # Passed by mod_epp https://github.com/mod-epp/mod-epp#requestscript-interface
    end

    def ensure_session_id_passed
      raise 'EPP session id is empty' unless epp_session_id.present?
    end

    def update_epp_session
      iptables_counter_update

      if session_timeout_reached?
        @api_user = current_user # cache current_user for logging
        epp_session.destroy

        epp_errors << {
          msg: t('session_timeout'),
          code: '2201'
        }

        handle_errors and return
      else
        epp_session.update_column(:updated_at, Time.zone.now)
      end
    end

    def session_timeout_reached?
      timeout = 5.minutes
      epp_session.updated_at < (Time.zone.now - timeout)
    end

    def iptables_counter_update
      return if ENV['iptables_counter_enabled'].blank? && ENV['iptables_counter_enabled'] != 'true'
      return if current_user.blank?
      counter_update(current_user.registrar_code, ENV['iptables_server_ip'])
    end

    def counter_update(registrar_code, ip)
      counter_proc = "/proc/net/xt_recent/#{registrar_code}"

      begin
        File.open(counter_proc, 'a') do |f|
          f.puts "+#{ip}"
        end
      rescue Errno::ENOENT => e
        logger.error "IPTABLES COUNTER UPDATE: cannot open #{counter_proc}: #{e}"
      rescue Errno::EACCES => e
        logger.error "IPTABLES COUNTER UPDATE: no permission #{counter_proc}: #{e}"
      rescue IOError => e
        logger.error "IPTABLES COUNTER UPDATE: cannot write #{ip} to #{counter_proc}: #{e}"
      end
    end

    def log_exception(exception)
      logger.error(([exception.message] + exception.backtrace).join($INPUT_RECORD_SEPARATOR))
      notify_airbrake(exception)
    end
  end
end
