class RegistrarPresenter
  def initialize(registrar:, view:)
    @registrar = registrar
    @view = view
  end

  delegate :name, to: :registrar

  delegate :email, to: :registrar

  delegate :phone, to: :registrar

  delegate :website, to: :registrar

  def language
    view.available_languages.key(registrar.language.to_sym)
  end

  private

  attr_reader :registrar
  attr_reader :view
end
