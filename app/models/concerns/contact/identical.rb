module Concerns::Contact::Identical
  extend ActiveSupport::Concern

  ATTRIBUTE_FILTER = %w[
    name
    ident
    ident_type
    ident_country_code
    phone
    email
  ]
  private_constant :ATTRIBUTE_FILTER

  def identical(registrar)
    self.class.where(attributes.slice(*ATTRIBUTE_FILTER)).where(registrar: registrar)
      .where.not(id: id).take
  end
end
