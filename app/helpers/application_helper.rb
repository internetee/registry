module ApplicationHelper
  def unstable_env
    return nil if Rails.env.production?
    Rails.env
  end

  def env_style
    return '' if unstable_env.nil?
    "background-image: url(#{image_path(unstable_env.to_s + '.png')});"
  end

  def ident_for(contact)
    case contact.ident_type
    when 'birthday'
      "#{contact.ident} [#{contact.ident_type}]"
    else
      "#{contact.ident} [#{contact.ident_country_code} #{contact.ident_type}]"
    end
  end
end
