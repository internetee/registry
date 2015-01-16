module ApplicationHelper
  def current_env
    if request.host == 'registry.gitlab.eu'
      :alpha
    elsif request.host == 'testepp.internet.ee'
      :staging
    elsif Rails.env.development?
      :development
    end
  end

  def env_style
    return '' if current_env.nil?
    "background-image: url(#{image_path(current_env.to_s + '.png')});"
  end
end
