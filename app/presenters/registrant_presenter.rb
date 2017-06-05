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

  private

  attr_reader :registrant
  attr_reader :view
end
