require 'test_helper'

class AdminAreaRegistrarsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @registrar = registrars(:bestnames)
    sign_in users(:admin)
  end

  def test_updates_registrar_optional_attributes
    new_iban = 'GB94BARC10201530093459'
    assert_not_equal new_iban, @registrar.iban

    patch admin_registrar_path(@registrar), params: { registrar: { iban: new_iban } }
    @registrar.reload

    assert_equal new_iban, @registrar.iban
  end
end