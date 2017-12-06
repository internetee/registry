require 'test_helper'

class RegistrarTest < ActiveSupport::TestCase
  def test_rejects_absent_accounting_customer_code
    registrar = Registrar.new(accounting_customer_code: nil)
    registrar.validate
    assert registrar.errors.added?(:accounting_customer_code, :blank)
  end
end
