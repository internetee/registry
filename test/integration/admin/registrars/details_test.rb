require 'test_helper'

class AdminAreaRegistrarDetailsTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::NumberHelper

  setup do
    sign_in users(:admin)
    @registrar = registrars(:complete)
  end

  def test_registrar_details
    visit admin_registrar_path(@registrar)
    assert_text 'Accounting customer code US0001'
    assert_text 'VAT number US12345'
    assert_text 'VAT rate 5.0%'
    assert_text 'Language English'
  end
end
