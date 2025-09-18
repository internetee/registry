require 'test_helper'

class AdminMassActionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess

  setup do
    @admin = users(:admin)
    sign_in @admin

    @valid_csv_path   = Rails.root.join('test/fixtures/files/mass_actions/valid_mass_force_delete_list.csv')
    @invalid_csv_path = Rails.root.join('test/fixtures/files/mass_actions/invalid_mass_force_delete_list.csv')
  end

  def post_mass_action(action: 'force_delete', file: @valid_csv_path, stub_result: nil)
    MassAction.stub(:process, stub_result) do
      post admin_mass_actions_path, params: {
        mass_action: action,
        entry_list: file && fixture_file_upload(file, 'text/csv')
      }
    end
  end

  def assert_flash_notice_includes(*expected_strings)
    expected_strings.each do |string|
      assert_includes flash[:notice], string
    end
  end

  def test_index_renders_successfully
    get admin_mass_actions_path
    assert_response :success
    assert_match 'Bulk actions', response.body
  end

  def test_index_requires_authentication
    sign_out @admin
    get admin_mass_actions_path
    assert_redirected_to new_admin_user_session_path
  end

  def test_create_with_valid_force_delete_data
    post_mass_action(stub_result: { ok: ['shop.test', 'airport.test'], fail: ['nonexistant.test'] })

    assert_redirected_to admin_mass_actions_path
    assert_flash_notice_includes 'shop.test', 'airport.test', 'Failed: ["nonexistant.test"]'
  end

  def test_create_with_invalid_data_returns_validation_error
    post_mass_action(file: @invalid_csv_path, stub_result: false)

    assert_redirected_to admin_mass_actions_path
    assert_includes flash[:notice], 'Dataset integrity validation failed for force_delete'
  end

  def test_create_with_invalid_action_type
    post_mass_action(action: 'invalid_action', stub_result: false)

    assert_redirected_to admin_mass_actions_path
    assert_includes flash[:notice], 'Dataset integrity validation failed for invalid_action'
  end

  def test_create_without_file_raises_error
    assert_raises(NoMethodError) do
      post_mass_action(file: nil)
    end
  end

  def test_create_requires_authentication
    sign_out @admin
    post_mass_action(stub_result: { ok: ['shop.test'], fail: [] })
    assert_redirected_to new_admin_user_session_path
  end

  def test_create_with_partial_success
    post_mass_action(stub_result: { ok: ['shop.test'], fail: ['airport.test', 'library.test'] })

    assert_redirected_to admin_mass_actions_path
    assert_flash_notice_includes 'shop.test', 'Failed: ["airport.test", "library.test"]'
  end

  def test_create_with_all_successful_operations
    post_mass_action(stub_result: { ok: %w[shop.test airport.test library.test], fail: [] })

    assert_redirected_to admin_mass_actions_path
    assert_flash_notice_includes 'shop.test', 'airport.test', 'library.test', 'Failed: []'
  end

  def test_create_with_all_failed_operations
    post_mass_action(stub_result: { ok: [], fail: %w[shop.test airport.test library.test] })

    assert_redirected_to admin_mass_actions_path
    assert_flash_notice_includes 'force_delete completed for []', 'Failed: ["shop.test", "airport.test", "library.test"]'
  end

  def test_create_with_exception_propagates
    assert_raises(StandardError) do
      post_mass_action(stub_result: ->(_a, _b) { raise StandardError, 'Unexpected error' })
    end
  end
end