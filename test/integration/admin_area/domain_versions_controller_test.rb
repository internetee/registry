require 'test_helper'

class AdminAreaDomainVersionsControllerIntegrationTest < ApplicationIntegrationTest
  setup do
    WebMock.allow_net_connect!
    sign_in users(:admin)

    @registrar = registrars(:bestnames)
    @domain = domains(:shop)
    
    # Ensure we have domain versions to test with
    @version = Version::DomainVersion.where(item_id: @domain.id).first
    skip "No domain versions found for testing" unless @version
  end

  def teardown
    super
  end

  def test_index_with_basic_search
    get admin_domain_versions_path, params: { q: { name: 'shop' } }
    
    assert_response :ok
    assert_includes response.body, 'shop.test'
  end

  def test_index_with_event_filter
    get admin_domain_versions_path, params: { q: { event: 'create' } }
    
    assert_response :ok
    assert_includes response.body, 'create'
  end

  def test_index_with_registrant_search
    get admin_domain_versions_path, params: { q: { registrant: 'john' } }
    
    assert_response :ok
  end

  def test_index_with_registrar_search
    get admin_domain_versions_path, params: { q: { registrar: 'bestnames' } }
    
    assert_response :ok
  end

  def test_index_with_date_range_filter
    get admin_domain_versions_path, params: { 
      q: { 
        created_at_gteq: '2023-01-01',
        created_at_lteq: '2023-12-31'
      }
    }
    
    assert_response :ok
  end

  def test_index_with_pagination
    get admin_domain_versions_path, params: { page: 2, results_per_page: 5 }
    
    assert_response :ok
  end

  def test_index_csv_export
    get admin_domain_versions_path, params: { format: :csv }
    
    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_includes response.body, 'Name,Registrant,Registrar,Action,Created at'
  end

  def test_show_current_domain
    get admin_domain_version_path(@version.id), params: { current: true, domain_id: @domain.id }
    
    assert_response :ok
    assert_includes response.body, @domain.name
  end

  def test_show_specific_version
    get admin_domain_version_path(@version.id)
    
    assert_response :ok
    assert_includes response.body, @version.event
  end

  def test_show_with_page_parameter
    get admin_domain_version_path(@version.id), params: { page: 2 }
    
    assert_response :ok
  end

  def test_search_endpoint_returns_expected_json
    expected_result = [{ 'id' => 1, 'display_key' => 'shop.test (Domain)' }]

    Version::DomainVersion.singleton_class.define_method(:search_by_query) { |*_args| expected_result }

    get search_admin_domain_versions_path, params: { q: 'shop' }
    
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal expected_result, json
  end

  def test_search_with_empty_query
    Version::DomainVersion.singleton_class.define_method(:search_by_query) { |*_args| [] }
    
    get search_admin_domain_versions_path, params: { q: '' }
    
    assert_response :ok
  end

  def test_index_with_complex_search_combination
    get admin_domain_versions_path, params: { 
      q: { 
        name: 'shop',
        event: 'update',
        registrant: 'john',
        registrar: 'bestnames'
      }
    }
    
    assert_response :ok
  end

  def test_index_with_empty_search_results
    get admin_domain_versions_path, params: { q: { name: 'nonexistent' } }
    
    assert_response :ok
  end

  def test_show_with_invalid_version_id
    assert_raises(ActiveRecord::RecordNotFound) do
      get admin_domain_version_path(999999)
    end
  end

  def test_show_with_invalid_domain_id
    assert_raises(ActiveRecord::RecordNotFound) do
      get admin_domain_version_path(999999), params: { current: true }
    end
  end
end
