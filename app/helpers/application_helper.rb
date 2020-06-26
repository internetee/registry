# rubocop:disable Rubocop/ModuleLength
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

  def current_commit_link
    hash = `git rev-parse --short HEAD`
    current_repo = `git remote get-url origin`.gsub('com:', 'com/')
                                              .gsub('git@', 'https://')
                                              .gsub('.git', '')

    link_to hash.to_s, "#{current_repo}/commit/#{hash}",
            class: 'footer-version-link',
            target: '_blank',
            rel: 'noopener'
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

    if model.updator.kind_of?(RegistrantUser)
      model.updator
    else
      link_to(model.updator, ['admin', model.updator])
    end
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

  def changing_css_class_audit(version, *attrs)
    return unless version
    css_class = "text-warning"

    if attrs.size == 1
      version.diff.to_h[attrs.first] && css_class
    else
      version.diff.to_h.slice(*attrs).any? && css_class
    end
  end

  def changing_css_class_action(version)
    return unless version

    css_class = 'text-red' if version.history_action == 'DELETE'
    css_class = 'text-green' if version.history_action == 'INSERT'
    css_class
  end

  def last_change_history_version(change:)
    object = Audit::ContactHistory.by_contact(change.contact_id).last
    link_to admin_contact_version_path(object), class: changing_css_class_action(change),
                                                target: '_blank',
                                                rel: 'noopener' do
      yield
    end
  end

  def last_contact_history_version(contact:)
    object = Audit::ContactHistory.by_contact(contact.id).last
    if object
      link_to admin_contact_version_path(object), target: '_blank', rel: 'noopener' do
        yield
      end
    else
      content_tag(:p) do
        yield
      end
    end
  end

  def legal_document_types
    types = LegalDocument::TYPES.dup
    types.delete('ddoc')
    ".#{types.join(',.')}"
  end

  def body_css_class
    [controller_path.split('/').map!(&:dasherize), action_name.dasherize, 'page'].join('-')
  end
end
# rubocop:enable Rubocop/ModuleLength
