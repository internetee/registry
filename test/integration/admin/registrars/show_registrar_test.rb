require 'test_helper'

class ShowRegistrarTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::NumberHelper

  setup do
    login_as users(:admin)
    @registrar = registrars(:bestnames)
    visit admin_registrar_path(@registrar)
  end

  def test_accounting_customer_code
    assert_text 'bestnames'
  end

  def test_language
    assert_text 'Language English'
  end
end
