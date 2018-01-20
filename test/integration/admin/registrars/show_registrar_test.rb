require 'test_helper'

class ShowRegistrarTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::NumberHelper

  def setup
    login_as users(:admin)
    @registrar = registrars(:bestnames)
    visit admin_registrar_path(@registrar)
  end

  def test_accounting_customer_code
    assert_text 'ACCOUNT001'
  end

  def test_language
    assert_text 'Language English'
  end
end
