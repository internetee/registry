class HealthCheckController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  rescue_from(StandardError) { head :service_unavailable }

  def show
    head :ok
  end
end
