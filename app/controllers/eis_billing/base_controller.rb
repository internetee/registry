module EisBilling
  class BaseController < ApplicationController
    skip_authorization_check # Temporary solution
    skip_before_action :verify_authenticity_token # Temporary solution
  end

  protected

  def logger
    @logger ||= Rails.logger
  end
end
