class RegistrantPresenter
  def initialize(registrant:, view:)
    @registrant = registrant
    @view = view
  end

  def name
    registrant.name
  end

  def ident
    registrant.ident
  end

  private

  attr_reader :registrant
  attr_reader :view
end
