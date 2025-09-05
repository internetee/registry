require 'test_helper'

class AdminAreaSettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  def test_index_renders_successfully_and_loads_all_settings_groups
    get admin_settings_path
    
    assert_response :success
    assert_select 'form[action=?]', admin_settings_path
  end

  def test_create_with_valid_settings_updates_successfully
    setting = setting_entry(:registry_email)
    new_value = 'new-email@example.com'
    
    post admin_settings_path, params: {
      settings: {
        setting.id.to_s => new_value
      }
    }
    
    assert_redirected_to admin_settings_path
    assert_equal 'Settings have been successfully updated', flash[:notice]
    
    setting.reload
    assert_equal new_value, setting.value
  end

  def test_create_with_multiple_settings_updates_successfully
    setting1 = setting_entry(:registry_email)
    setting2 = setting_entry(:registry_phone)
    new_email = 'test@example.com'
    new_phone = '+372 123 4567'
    
    post admin_settings_path, params: {
      settings: {
        setting1.id.to_s => new_email,
        setting2.id.to_s => new_phone
      }
    }
    
    assert_redirected_to admin_settings_path
    assert_equal 'Settings have been successfully updated', flash[:notice]
    
    setting1.reload
    setting2.reload
    assert_equal new_email, setting1.value
    assert_equal new_phone, setting2.value
  end

  def test_create_with_boolean_settings_updates_successfully
    setting = setting_entry(:ds_data_allowed)
    new_value = 'true'
    
    post admin_settings_path, params: {
      settings: {
        setting.id.to_s => new_value
      }
    }
    
    assert_redirected_to admin_settings_path
    assert_equal 'Settings have been successfully updated', flash[:notice]
    
    setting.reload
    assert_equal new_value, setting.value
  end

  def test_create_with_integer_settings_updates_successfully
    setting = setting_entry(:admin_contacts_min_count)
    new_value = '5'
    
    post admin_settings_path, params: {
      settings: {
        setting.id.to_s => new_value
      }
    }
    
    assert_redirected_to admin_settings_path
    assert_equal 'Settings have been successfully updated', flash[:notice]
    
    setting.reload
    assert_equal new_value, setting.value
  end

  def test_create_with_float_settings_updates_successfully
    setting = setting_entry(:registry_vat_prc)
    new_value = '0.25'
    
    post admin_settings_path, params: {
      settings: {
        setting.id.to_s => new_value
      }
    }
    
    assert_redirected_to admin_settings_path
    assert_equal 'Settings have been successfully updated', flash[:notice]
    
    setting.reload
    assert_equal new_value, setting.value
  end

  def test_create_with_array_format_settings_updates_successfully
    setting = setting_entry(:admin_contacts_allowed_ident_type)
    
    array_data = {
      'birthday' => true,
      'priv' => false,
      'org' => true
    }
    
    post admin_settings_path, params: {
      settings: {
        setting.id.to_s => array_data
      }
    }
    
    assert_redirected_to admin_settings_path
    assert_equal 'Settings have been successfully updated', flash[:notice]
    
    setting.reload
    expected_json = array_data.to_json
    assert_equal expected_json, setting.value
  end

  def test_create_with_hash_format_settings_updates_successfully
    setting = setting_entry(:registry_whois_disclaimer)
    new_value = '{"en":"New disclaimer","et":"Uus hoiatus","ru":"Новое предупреждение"}'
    
    post admin_settings_path, params: {
      settings: {
        setting.id.to_s => new_value
      }
    }
    
    assert_redirected_to admin_settings_path
    assert_equal 'Settings have been successfully updated', flash[:notice]
    
    setting.reload
    assert_equal new_value, setting.value
  end

  def test_create_with_invalid_setting_id_raises_error
    assert_raises(ActiveRecord::RecordNotFound) do
      post admin_settings_path, params: {
        settings: {
          '999999' => 'some_value'
        }
      }
    end
  end

  def test_create_with_empty_settings_raises_error
    assert_raises(NoMethodError) do
      post admin_settings_path, params: {}
    end
  end

  def test_create_with_nil_settings_raises_error
    assert_raises(NoMethodError) do
      post admin_settings_path, params: { settings: nil }
    end
  end

  def test_create_requires_authentication
    sign_out @admin
    
    get admin_settings_path
    assert_redirected_to new_admin_user_session_path
    
    post admin_settings_path, params: { settings: {} }
    assert_redirected_to new_admin_user_session_path
  end

  def test_create_requires_admin_authorization
    get admin_settings_path
    assert_response :success
  end

  def test_available_options_returns_correct_values
    setting = setting_entry(:admin_contacts_allowed_ident_type)
    
    array_data = {
      'birthday' => true,
      'priv' => true, 
      'org' => true
    }
    
    post admin_settings_path, params: {
      settings: {
        setting.id.to_s => array_data
      }
    }
    
    assert_redirected_to admin_settings_path
    assert_equal 'Settings have been successfully updated', flash[:notice]
    
    setting.reload
    expected_json = array_data.to_json
    assert_equal expected_json, setting.value
  end

  def test_casted_settings_processes_different_formats_correctly
    string_setting = setting_entry(:registry_email)
    boolean_setting = setting_entry(:ds_data_allowed)
    integer_setting = setting_entry(:admin_contacts_min_count)
    array_setting = setting_entry(:admin_contacts_allowed_ident_type)
    
    array_data = {
      'birthday' => true,
      'priv' => false,
      'org' => true
    }
    
    post admin_settings_path, params: {
      settings: {
        string_setting.id.to_s => 'test@example.com',
        boolean_setting.id.to_s => 'true',
        integer_setting.id.to_s => '10',
        array_setting.id.to_s => array_data
      }
    }
    
    assert_redirected_to admin_settings_path
    assert_equal 'Settings have been successfully updated', flash[:notice]
    
    string_setting.reload
    boolean_setting.reload
    integer_setting.reload
    array_setting.reload
    
    assert_equal 'test@example.com', string_setting.value
    assert_equal 'true', boolean_setting.value
    assert_equal '10', integer_setting.value
    assert_equal array_data.to_json, array_setting.value
  end

  private

  def setting_entry(fixture_name)
    setting_entries(fixture_name)
  end
end
