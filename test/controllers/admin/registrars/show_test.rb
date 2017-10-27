require 'test_helper'

class RegistrarsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login_as create(:admin_user)
  end

  def test_accounting_customer_code
    registrar = create(:registrar, accounting_customer_code: 'test accounting customer code')
    visit admin_registrar_path(registrar)
    assert_text 'test accounting customer code'
  end
end
