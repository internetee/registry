class Contact::Ident
  include ActiveModel::Model

  attr_accessor :code, :type, :country_code

  validates :code, presence: true
  validates :code, national_id: true, if: :national_id?
  validates :code, reg_no: true, if: :reg_no?
  validates :code, iso8601: { date_only: true }, if: :birthday?

  validates :type, presence: true, inclusion: { in: proc { types } }
  validates :country_code, presence: true, iso31661_alpha2: true
  validates_with MismatchValidator
  validates_with BirthDateValidator, if: :birthday?

  def self.epp_code_map
    {
      '2003' => [
        %i[code blank],
        %i[type blank],
        %i[country_code blank],
      ],
      '2005' => [
        %i[base mismatch],
        %i[code invalid_national_id],
        %i[code invalid_reg_no],
        %i[code invalid_iso8601_date],
        %i[code invalid_birth_date],
        %i[country_code invalid_iso31661_alpha2],
      ]
    }
  end

  def self.types
    %w[org priv birthday]
  end

  def marked_for_destruction?
    false
  end

  def birthday?
    type == 'birthday'
  end

  def national_id?
    type == 'priv'
  end

  def reg_no?
    type == 'org'
  end

  def country
    Country.new(country_code)
  end

  def ==(other_ident)
    if other_ident.is_a?(self.class)
      (code == other_ident.code) &&
        (type == other_ident.type) &&
        (country_code == other_ident.country_code)
    else
      false
    end
  end

  private

  # https://github.com/rails/rails/issues/1513
  def validation_context=(_value)
    ;
  end
end
