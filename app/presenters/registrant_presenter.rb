class RegistrantPresenter
  delegate :name,
           :ident,
           :phone,
           :email,
           :priv?,
           :id_code,
           :reg_no,
           :street, :city, :state, :zip, :country,
           :ident_country,
           :linked?,
           to: :registrant

  def initialize(registrant:, view:)
    @registrant = registrant
    @view = view
  end

  def country(locale: I18n.locale)
    registrant.country.translation(locale)
  end

  def ident_country(locale: I18n.locale)
    registrant.ident_country.translation(locale)
  end

  def domain_names_with_roles(locale: I18n.locale, line_break: "\n")
    lines = []

    registrant.domain_names_with_roles.each do |domain_name, roles|
      lines << "#{domain_name} (#{roles.map { |role| role.to_s.classify.constantize.model_name.human(locale: locale) }
                                      .join(', ')})"
    end

    lines.join(line_break).html_safe
  end

  private

  attr_reader :registrant
  attr_reader :view
end
