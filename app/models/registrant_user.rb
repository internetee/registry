class RegistrantUser < User
  attr_accessor :registrar_typeahead

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability
end
