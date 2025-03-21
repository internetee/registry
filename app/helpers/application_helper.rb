module ApplicationHelper
  def unstable_env
    return nil if Rails.env.production?
    Rails.env
  end

  def env_style
    return '' if unstable_env.nil?

    "background-image: url(#{image_path("#{unstable_env}.png")});"
  end

  def ident_for(contact)
    ident = contact.ident
    description = "[#{contact.ident_country_code} #{contact.ident_type}]"
    description.prepend("#{ident} ") if ident.present?

    description
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
    link_to(model.creator, [:admin, model.creator])
  end

  def updator_link(model)
    return 'not present' if model.blank?
    return 'unknown'     if model.updator.blank?
    return model.updator if model.updator.is_a? String

    if model.updator.kind_of?(RegistrantUser)
      model.updator
    else
      link_to(model.updator, [:admin, model.updator])
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
    types.delete('ddoc')
    ".#{types.join(',.')}"
  end

  def body_css_class
    [controller_path.split('/').map!(&:dasherize), action_name.dasherize, 'page'].join('-')
  end

  def db_hint_options
    result = {}
    # Get all tables from the database
    ActiveRecord::Base.connection.tables.each do |table_name|
      # Skip internal Rails tables
      next if table_name.match(/^(ar_internal_metadata|schema_migrations)$/)

      # Get all columns for each table
      columns = ActiveRecord::Base.connection.columns(table_name).map(&:name)
      result[table_name] = columns
    end
    result
  end
end
