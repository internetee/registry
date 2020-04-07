require 'test_helper'

class BankStatementTest < ActiveSupport::TestCase
  def test_valid_bank_statement_fixture_is_valid
    assert valid_bank_statement.valid?, proc { valid_bank_statement.errors.full_messages }
  end

  def test_invalid_without_bank_code
    bank_statement = valid_bank_statement
    bank_statement.bank_code = ''
    assert bank_statement.invalid?
  end

  def test_invalid_without_iban
    bank_statement = valid_bank_statement
    bank_statement.iban = ''
    assert bank_statement.invalid?
  end

  private

  def valid_bank_statement
    bank_statements(:one)
  end

  def test_stores_history
    bank_statement = valid_bank_statement
    bank_statement.bank_code = '5678'

    assert_difference 'bank_statement.versions.count', 1 do
      bank_statement.save!
    end
  end
end
