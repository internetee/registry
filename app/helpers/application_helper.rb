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
    if contact.kind_of? Hash
      ident_country_code = contact[:ident_country_code]
      ident_type = contact[:ident_type]
      ident = contact[:ident]
    else
      ident_country_code = contact.ident_country_code
      ident_type = contact.ident_type
      ident = contact.ident
    end

    case ident_type
    when 'birthday'
      "#{ident} [#{ident_type}]"
    else
      "#{ident} [#{ident_country_code} #{ident_type}]"
    end
  end

  def creator_link(model)
    return 'not present' if model.blank?
    return 'unknown'     if model.creator.blank?
    return model.creator if model.creator.is_a? String

    # can be api user or some other user
    link_to(model.creator, ['admin', model.creator])
  end

  def updator_link(model)
    return 'not present' if model.blank?
    return 'unknown'     if model.updator.blank?
    return model.updator if model.updator.is_a? String

    # can be api user or some other user
    link_to(model.updator, ['admin', model.updator])
  end
end
