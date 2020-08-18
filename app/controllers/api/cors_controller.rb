module Api
  class CorsController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_authorization_check

    def cors_preflight_check
      set_access_control_headers
      render plain: ''
    end

    def set_access_control_headers
      response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
      response.headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, ' \
                                                         'Authorization, Token, Auth-Token, '\
                                                         'Email, X-User-Token, X-User-Email'
      response.headers['Access-Control-Max-Age'] = '3600'
    end
  end
end
