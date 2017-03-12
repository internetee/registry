class RegistrantPresenter
  delegate :name, :ident, :email, :priv?, :street, :city, :id_code, :reg_no, to: :registrant

  def initialize(registrant:, view:)
    @registrant = registrant
    @view = view
  end

  def country

  end

  private

  attr_reader :registrant
  attr_reader :view
end
