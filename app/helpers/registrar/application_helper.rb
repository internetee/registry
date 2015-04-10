module Registrar
  module ApplicationHelper
    def env_style
      return '' if unstable_env.nil?
      "background-image: url(#{image_path("registrar/bg-#{unstable_env}.png")});"
    end

    def pagination_details
      params[:page] ||= 1
      limit = ENV['depp_records_on_page'] || 20
      offset = ((params[:page].to_i - 1) * limit.to_i)
      [limit, offset]
    end
  end
end
