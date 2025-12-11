require 'test_helper'

class AdminAreaRegistrarsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    ENV['accr_expiry_months'] = '24'
    @api_user = users(:api_bestnames)
    sign_in users(:admin)
  end

  def test_set_test_date_to_api_user
    assert_nil @api_user.accreditation_date

    post set_test_date_to_api_user_admin_registrars_path(@api_user.registrar),
         params: { user_api_id: @api_user.id },
         headers: { 'HTTP_REFERER' => admin_registrar_path(@api_user.registrar) }
    @api_user.reload
    assert_equal @api_user.accreditation_date.to_date, Time.zone.now.to_date
    assert_equal @api_user.accreditation_expire_date.to_date, Time.zone.now.to_date + 24.months
  end

  def test_index_api_users_listings
    [
      {},
      { q: { registrar_id: @api_user.registrar_id } }
    ].each do |params|
      get admin_api_users_path, params: params
      assert_response :success
      assert_select 'table'
      assert_select 'table tr', minimum: 2
    end
  end

  def test_index_pagination_and_page_parameter
    get admin_api_users_path, params: { results_per_page: 1, page: 2 }
    assert_response :success

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

  def test_destroy_api_user
    api_user = users(:api_bestnames)

    # Removing epp_session from database before deleting the api user
    EppSession.where(user_id: api_user.id).destroy_all

    assert_difference('ApiUser.count', -1) do
      delete admin_registrar_api_user_path(api_user.registrar, api_user)
    end

    assert_redirected_to admin_registrar_path(api_user.registrar)
    assert_not ApiUser.exists?(api_user.id)
  end
end
