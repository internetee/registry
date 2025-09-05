require 'test_helper'

class AdminContactsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess

  setup do
    @admin = users(:admin)
    sign_in @admin

    @contact = contacts(:william)
    @contact_without_country = contacts(:invalid)
  end

  def test_index_renders_successfully
    get admin_contacts_path
    assert_response :success
    assert_match @contact.name, response.body
    assert_match @contact.code, response.body
    assert_match @contact.registrar.name, response.body
  end

  def test_index_with_search_parameters
    get admin_contacts_path, params: { q: { name_cont: 'william' } }
    assert_response :success
    assert_match @contact.name, response.body
  end

  def test_index_with_status_filter
    get admin_contacts_path, params: { statuses_contains: ['ok'] }
    assert_response :success
    assert_match @contact.name, response.body
  end

  def test_index_with_domain_contacts_type_filter
    get admin_contacts_path, params: { q: { domain_contacts_type_in: ['registrant'] } }
    assert_response :success
  end

  def test_index_with_no_country_code_filter
    get admin_contacts_path, params: { only_no_country_code: '1' }
    assert_response :success
  end

  def test_index_with_results_per_page
    get admin_contacts_path, params: { results_per_page: 5 }
    assert_response :success
  end

  def test_index_with_pagination
    get admin_contacts_path, params: { page: 2 }
    assert_response :success
  end

  def test_index_with_date_filters
    get admin_contacts_path, params: { 
      q: { 
        created_at_lteq: '2010-07-06',
        updated_at_gteq: '2010-07-05'
      }
    }
    assert_response :success
  end

  def test_search_action
    assert_raises(NoMethodError) do
      get search_admin_contacts_path, params: { q: 'william' }
    end
  end

  def test_edit_action
    get edit_admin_contact_path(@contact)
    assert_response :success
    assert_match @contact.name, response.body
  end

  def test_update_success
    patch admin_contact_path(@contact), params: { 
      contact: { 
        statuses: ['ok', 'linked'],
        status_notes_array: ['Note 1', 'Note 2']
      }
    }
    
    assert_redirected_to admin_contact_path(@contact)
    assert_equal I18n.t('contact_updated'), flash[:notice]
    
    @contact.reload
    assert_includes @contact.statuses, 'ok'
    assert_includes @contact.statuses, 'linked'
  end

  def test_update_with_empty_statuses
    patch admin_contact_path(@contact), params: { 
      contact: { 
        statuses: ['ok', '', 'linked', '   '],
        status_notes_array: ['Note 1']
      }
    }
    
    assert_redirected_to admin_contact_path(@contact)
    assert_equal I18n.t('contact_updated'), flash[:notice]
    
    @contact.reload
    assert_includes @contact.statuses, 'ok'
    assert_includes @contact.statuses, 'linked'
    assert_not_includes @contact.statuses, ''
    assert_not_includes @contact.statuses, '   '
  end

  def test_update_failure
    contact = @contact
    Contact.stub_any_instance(:update, false) do
      patch admin_contact_path(contact), params: { 
        contact: { statuses: ['invalid_status'] }
      }
    end
    
    assert_response :success
    assert_match I18n.t('failed_to_update_contact'), flash[:alert]
    assert_match 'Edit:', response.body
  end

  def test_update_without_contact_params
    patch admin_contact_path(@contact), params: {}
    
    assert_redirected_to admin_contact_path(@contact)
    assert_equal I18n.t('contact_updated'), flash[:notice]
    
    @contact.reload
    assert_includes @contact.statuses, 'ok'
  end

  def test_show_action
    get admin_contact_path(@contact)
    assert_response :success
    assert_match @contact.name, response.body
    assert_match @contact.code, response.body
  end

  def test_show_with_nonexistent_contact
    assert_raises(ActiveRecord::RecordNotFound) do
      get admin_contact_path(999999)
    end
  end

  def test_index_csv_format
    get admin_contacts_path, params: { format: :csv }
    assert_response :success
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_match 'attachment', response.headers['Content-Disposition']
  end

  def test_index_json_format
    assert_raises(ActionController::UnknownFormat) do
      get admin_contacts_path, params: { format: :json }
    end
  end

  def test_filter_by_flags_with_country_code
    get admin_contacts_path, params: { only_no_country_code: '0' }
    assert_response :success
  end

  def test_normalize_search_parameters_with_invalid_date
    get admin_contacts_path, params: { 
      q: { created_at_lteq: 'invalid_date' }
    }
    assert_response :success
  end

  def test_ident_types_helper_method
    get admin_contacts_path
    assert_response :success
  end

  def test_domain_filter_params_helper_method
    get admin_contacts_path, params: { domain_filter: 'test' }
    assert_response :success
  end

  def test_authorization_required
    sign_out @admin
    get admin_contacts_path
    assert_redirected_to new_admin_user_session_path
  end

  def test_contact_not_found_in_update
    assert_raises(ActiveRecord::RecordNotFound) do
      patch admin_contact_path(999999), params: { 
        contact: { statuses: ['ok'] }
      }
    end
  end

  def test_contact_not_found_in_edit
    assert_raises(ActiveRecord::RecordNotFound) do
      get edit_admin_contact_path(999999)
    end
  end
end
