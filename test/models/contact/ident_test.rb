require 'test_helper'

class ContactIdentTest < ActiveSupport::TestCase
  def test_valid_ident_is_valid
    assert valid_ident.valid?, proc { valid_ident.errors.full_messages }
  end

  def test_invalid_without_code
    ident = valid_ident
    ident.code = ''
    assert ident.invalid?
  end

  def test_validates_date_of_birth
    ident = valid_ident
    ident.type = 'birthday'

    ident.code = '2010-07-05'
    assert ident.valid?

    ident.code = '2010-07-0'
    assert ident.invalid?
  end

  # https://en.wikipedia.org/wiki/National_identification_number#Estonia
  def test_country_specific_national_id_format_validation
    country = Country.new('EE')
    ident = valid_ident
    ident.type = 'priv'
    ident.country_code = country.alpha2

    ident.code = 'invalid'
    assert ident.invalid?
    assert_includes ident.errors.full_messages, "Code does not conform to national identification number format of #{country}"

    ident.code = '47101010033'
    assert ident.valid?

    ident.country_code = 'US'
    ident.code = 'any'
    assert ident.valid?
  end

  def test_country_specific_company_registration_number_format_validation
    country = Country.new('EE')
    ident = valid_ident
    ident.type = 'org'
    ident.country_code = country.alpha2
    allowed_length = 8

    ident.code = '1' * allowed_length.pred
    assert ident.invalid?
    assert_includes ident.errors.full_messages, "Code does not conform to registration number format of #{country}"

    ident.code = '1' * allowed_length.next
    assert ident.invalid?

    ident.code = '1' * allowed_length
    assert ident.valid?

    ident.country_code = 'US'
    ident.code = 'any'
    assert ident.valid?
  end

  def test_invalid_without_type
    ident = valid_ident
    ident.type = ''
    assert ident.invalid?
  end

  def test_validates_type
    assert_not_includes Ident.types, 'invalid'
    ident = valid_ident
    ident.type = 'invalid'

    assert ident.invalid?
  end

  def test_invalid_without_country_code
    ident = valid_ident
    ident.country_code = ''
    assert ident.invalid?
  end

  def test_validates_country_code_format
    ident = valid_ident

    ident.country_code = 'invalid'
    assert ident.invalid?

    ident.country_code = 'US'
    assert ident.valid?
  end

  def test_validates_for_mismatches
    ident = valid_ident
    mismatch = Ident::MismatchValidator.mismatches.first
    ident.type = mismatch.type
    ident.country_code = mismatch.country.alpha2

    assert ident.invalid?
    assert_includes ident.errors.full_messages, %(Ident type "#{ident.type}" is invalid for #{ident.country})
  end

  def test_returns_types
    assert_equal %w[org priv birthday], Ident.types
  end

  def test_returns_country
    country_code = 'US'
    ident = Ident.new(country_code: country_code)
    assert_equal Country.new(country_code), ident.country
  end

  def test_equality
    assert_equal Ident.new(code: 'code', type: 'type', country_code: 'US'),
                 Ident.new(code: 'code', type: 'type', country_code: 'US')
    assert_not_equal Ident.new(code: 'code', type: 'type', country_code: 'US'),
                     Ident.new(code: 'code', type: 'type', country_code: 'GB')
  end

  private

  def valid_ident
    Ident.new(code: '1234', type: 'priv', country_code: 'US')
  end
end
