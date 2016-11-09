class RegistrantPresenter
  delegate :name, :ident, :email, :priv?, to: :registrant

  def initialize(registrant:, view:)
    @registrant = registrant
    @view = view
  end

  private

  attr_reader :registrant
  attr_reader :view
end
