require 'test_helper'

class RegistrarTest < ActiveSupport::TestCase
  def setup
    @registrar = registrars(:valid)
  end

  def test_valid
    assert @registrar.valid?
  end

  def test_rejects_absent_accounting_customer_code
    @registrar.accounting_customer_code = nil
    @registrar.validate
    assert @registrar.invalid?
  end

  def test_requires_country_code
    @registrar.country_code = nil
    @registrar.validate
    assert @registrar.invalid?
  end
end
