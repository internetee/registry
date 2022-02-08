module EisBilling
  class BaseController < ApplicationController
    # load_and_authorize_resource

    skip_authorization_check # Temporary solution
    skip_before_action :verify_authenticity_token # Temporary solution
  end

  protected

  def logger
    @logger ||= Rails.logger
  end
end
