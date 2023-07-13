module ErrorAndLogHandler
  extend ActiveSupport::Concern

  included do
    around_action :log_request
  end

  private

  # rubocop:disable Metrics/MethodLength
  def log_request
    yield
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found
  rescue ActionController::ParameterMissing, Apipie::ParamMissing => e
    handle_parameter_missing(e)
  rescue Apipie::ParamInvalid => e
    handle_param_invalid(e)
  rescue CanCan::AccessDenied => e
    handle_access_denied(e)
  rescue Shunter::ThrottleError => e
    handle_throttle_error(e)
  ensure
    create_repp_log
  end
  # rubocop:enable Metrics/MethodLength

  def handle_record_not_found
    @response = { code: 2303, message: 'Object does not exist' }
    render(json: @response, status: :not_found)
  end

  def handle_parameter_missing(error)
    @response = { code: 2003, message: error.message.gsub(/\n/, '. ') }
    render(json: @response, status: :bad_request)
  end

  def handle_param_invalid(error)
    @response = { code: 2005, message: error.message.gsub(/\n/, '. ') }
    render(json: @response, status: :bad_request)
  end

  def handle_access_denied(error)
    @response = { code: 2201, message: 'Authorization error' }
    logger.error error.to_s
    render(json: @response, status: :unauthorized)
  end

  def handle_throttle_error(error)
    @response = { code: 2502, message: Shunter.default_error_message }
    logger.error error.to_s unless Rails.env.test?
    render(json: @response, status: :bad_request)
  end

  def create_repp_log
    log_attributes = build_log_attributes
    ApiLog::ReppLog.create(log_attributes)
  end

  def build_log_attributes
    {
      request_path: request.path, ip: request.ip,
      request_method: request.request_method,
      request_params: build_request_params_json,
      uuid: request.try(:uuid),
      response: @response.to_json,
      response_code: response.status,
      api_user_name: current_user.try(:username),
      api_user_registrar: current_user.try(:registrar).try(:to_s)
    }
  end

  def build_request_params_json
    request.params.except('route_info').to_json
  end

  def logger
    Rails.logger
  end
end
