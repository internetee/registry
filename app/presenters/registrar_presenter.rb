class RegistrarPresenter
  def initialize(registrar:, view:)
    @registrar = registrar
    @view = view
  end

  def name
    registrar.name
  end

  def email
    registrar.email
  end

  def phone
    registrar.phone
  end

  def website
    registrar.website
  end

  def language
    view.available_languages.key(registrar.language.to_sym)
  end

  private

  attr_reader :registrar
  attr_reader :view
end
