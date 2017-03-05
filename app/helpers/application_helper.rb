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
    if contact.is_a? Hash
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
      "#{ident} [#{ident_country_code} #{ident_type}]"
      else
        if ident.present?
          "#{ident} [#{ident_country_code} #{ident_type}]"
        else
          "[#{ident_country_code} #{ident_type}]"
        end

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

  def currency(amount)
    amount ||= 0
    format("%01.2f", amount.round(2)).sub(/\./, ',')
  end

  def plain_username(username)
    username ||= ''
    username.split(':').last.to_s.strip
  end

  def custom_sort_link(title, param_name)
    sort = params.fetch(:sort, {})[param_name]
    order = {"asc"=>"desc", "desc"=>"asc"}[sort] || "asc"


    if params.fetch(:sort, {}).include?(param_name)
      title += (sort == "asc" ? " ▲" : " ▼")
    end

    link_to(title, url_for(sort: {param_name => order}), class: "sort_link #{order}")
  end

  def changing_css_class(version, *attrs)
    return unless version
    css_class = "text-warning"

    if attrs.size == 1
      version.object_changes.to_h[attrs.first] && css_class
    else
      version.object_changes.to_h.slice(*attrs).any? && css_class
    end
  end

  def legal_document_types
    types = LegalDocument::TYPES.dup
    ".#{types.join(',.')}"
  end
end
