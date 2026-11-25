require 'test_helper'

class AdminAreaRegistrarsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    ENV['accr_expiry_months'] = '24'
    @api_user = users(:api_bestnames)
    sign_in users(:admin)
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
