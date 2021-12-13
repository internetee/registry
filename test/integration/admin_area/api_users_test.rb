require 'test_helper'

class AdminAreaRegistrarsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @api_user = users(:api_bestnames)
    sign_in users(:admin)
  end

  def test_set_test_date_to_api_user
    # ENV['registry_demo_registrar_api_user_url'] = 'http://testapi.test'

    date = Time.zone.now - 10.minutes

    api_user = @api_user.dup
    api_user.accreditation_date = date
    api_user.accreditation_expire_date = api_user.accreditation_date + 1.year
    api_user.save

    assert_nil @api_user.accreditation_date
    assert_equal api_user.accreditation_date, date

    # api_v1_accreditation_center_show_api_user_url
    stub_request(:get, "http://registry.test:3000/api/v1/accreditation_center/show_api_user?identity_code=#{@api_user.identity_code}&username=#{@api_user.username}").
      with(
        headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
        }).to_return(status: 200, body: { code: 200, user_api: api_user }.to_json, headers: {})
    post set_test_date_to_api_user_admin_registrars_path, params: { user_api_id: @api_user.id }, headers: { "HTTP_REFERER" => root_path }
    @api_user.reload
    assert_equal @api_user.accreditation_date.to_date, api_user.accreditation_date.to_date
    assert_equal @api_user.accreditation_expire_date.to_date, api_user.accreditation_expire_date.to_date
  end
end
