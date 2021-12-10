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

    stub_request(:get, "http://registry.test:3000/api/v1/accreditation_center/results?registrar_name=#{@registrar.name}").
    with(
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Ruby'
      }).to_return(status: 200, body: { code: 200, registrar_users: [api_user] }.to_json, headers: {})

    post set_test_date_admin_registrars_path, params: { registrar_id: @registrar.id }, headers: { "HTTP_REFERER" => root_path }
    @registrar.reload

    assert_equal @registrar.api_users.first.accreditation_date.to_date,  api_user.accreditation_date.to_date
    assert_equal @registrar.api_users.first.accreditation_expire_date.to_date,  api_user.accreditation_expire_date.to_date
  end
end
