class Contact::Ident
  include ActiveModel::Model

  attr_accessor :code
  attr_accessor :type
  attr_accessor :country_code

  validates :code, presence: true, code: true
  validates :code, iso8601: { date_only: true }, if: :birthday?
  validates :type, presence: true, inclusion: { in: proc { types } }
  validates :country_code, presence: true, iso31661_alpha2: true
  validate :mismatched

  def self.epp_code_map
    {
      '2003' => [
        [:code, :blank],
        [:type, :blank],
        [:country_code, :blank]
      ],
      '2005' => [
        [:base, :mismatch],
        [:code, :invalid_national_id],
        [:code, :invalid_reg_no],
        [:code, :invalid_iso8601],
        [:country_code, :invalid_iso31661_alpha2]
      ]
    }
  end

  def self.types
    %w[org priv birthday]
  end

  Mismatch = Struct.new(:type, :country)

  def self.mismatches
    [
      Mismatch.new('birthday', Country.new('EE'))
    ]
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

  private

  # https://github.com/rails/rails/issues/1513
  def validation_context=(_value); end

  def mismatched
    mismatched = self.class.mismatches.include?(Mismatch.new(type, country))
    errors.add(:base, :mismatch, type: type, country: country) if mismatched
  end
end
