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

  def test_set_test_date
    api_user = @registrar.api_users.first.dup
    api_user.accreditation_date = Time.zone.now - 10.minutes
    api_user.accreditation_expire_date = api_user.accreditation_date + 1.year
    api_user.save

    assert_nil @registrar.api_users.first.accreditation_date

    Spy.on_instance_method(Actions::GetAccrResultsFromAnotherDb, :get_current_registrars_users).and_return([api_user])

    post set_test_date_admin_registrars_path, params: { registrar_id: @registrar.id }
    @registrar.reload

    assert_equal @registrar.api_users.first.accreditation_date.to_date,  api_user.accreditation_date.to_date
    assert_equal @registrar.api_users.first.accreditation_expire_date.to_date,  api_user.accreditation_expire_date.to_date
  end
end
