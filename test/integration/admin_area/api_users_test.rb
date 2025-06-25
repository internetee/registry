require 'test_helper'

class AdminAreaRegistrarsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    ENV['registry_demo_registrar_api_user_url'] = 'http://registry.test:3000/api/v1/accreditation_center/show_api_user'
    ENV['registry_demo_registrar_port'] = '3000'
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
    stub_request(:get, "http://registry.test:3000/api/v1/accreditation_center/show_api_user?username=#{@api_user.username}&identity_code=#{@api_user.identity_code}")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: { code: 200, user_api: api_user }.to_json, headers: {})
    post set_test_date_to_api_user_admin_registrars_path, params: { user_api_id: @api_user.id }, headers: { 'HTTP_REFERER' => root_path }
    @api_user.reload
    assert_equal @api_user.accreditation_date.to_date, api_user.accreditation_date.to_date
    assert_equal @api_user.accreditation_expire_date.to_date, api_user.accreditation_expire_date.to_date
  end

  def test_index_api_users
    get admin_api_users_path
    assert_response :success
    
    assert_select 'table'
    assert_select 'table tr', minimum: 2
  end

  def test_index_api_users_with_registrar_id
    get admin_api_users_path, params: {q: { registrar_id: @api_user.registrar_id } }
    assert_response :success
    assert_select 'table tr', minimum: 2
  end

  def test_index_with_pagination
    get admin_api_users_path, params: { results_per_page: 1 }
    assert_response :success
  
    assert_select 'table tr', minimum: 2
    assert_select 'table tr', maximum: 2  
    assert_select 'table tr', count: 2
  end

  def test_update_api_user_successfully
    api_user = users(:api_bestnames)
    new_username = 'updated_username'
    
    patch admin_registrar_api_user_path(api_user.registrar, api_user), 
          params: { api_user: { username: new_username } }
    
    assert_redirected_to admin_registrar_api_user_path(api_user.registrar, api_user)
    api_user.reload
    assert_equal new_username, api_user.username
  end

  def test_update_api_user_with_invalid_data
    api_user = users(:api_bestnames)
    
    patch admin_registrar_api_user_path(api_user.registrar, api_user), 
          params: { api_user: { username: '' } }
    
    assert_response :success # Rails renders the form again with errors - 200
    assert_select 'div.alert.alert-danger', /Username.*(missing|can't be blank)/i
  end

  def test_remove_test_date_from_api_user
    api_user = users(:api_bestnames)
    api_user.update_columns(
      accreditation_date: Time.zone.now,
      accreditation_expire_date: Time.zone.now + 1.year
    )
    
    assert_not_nil api_user.accreditation_date
    assert_not_nil api_user.accreditation_expire_date
    
    referer_path = admin_registrar_path(api_user.registrar)
    post remove_test_date_to_api_user_admin_registrars_path(api_user.registrar), 
         params: { user_api_id: api_user.id },
         headers: { 'HTTP_REFERER' => referer_path }
    
    assert_redirected_to referer_path
    
    api_user.reload
    assert_nil api_user.accreditation_date
    assert_nil api_user.accreditation_expire_date
  end
end
