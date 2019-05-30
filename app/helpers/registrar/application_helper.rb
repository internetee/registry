module Registrar::ApplicationHelper
  def env_style
    return '' if unstable_env.nil?

    "background-image: url(#{image_path("registrar/bg-#{unstable_env}.png")});"
  end
end
