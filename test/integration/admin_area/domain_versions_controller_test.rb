require 'test_helper'

class AdminAreaDomainVersionsControllerIntegrationTest < ApplicationIntegrationTest
  setup do
    WebMock.allow_net_connect!
    sign_in users(:admin)

    @registrar = registrars(:bestnames)
    @domain = domains(:shop)
    
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

  def test_show_create_version_of_deleted_domain
    deleted_item_id = next_unused_domain_id
    create_version = Version::DomainVersion.create!(
      item_type: 'Domain',
      item_id: deleted_item_id,
      event: 'create',
      whodunnit: users(:admin).id.to_s,
      object: nil,
      object_changes: {
        'name' => [nil, 'ghost.test'],
        'registrar_id' => [nil, @registrar.id],
        'registrant_id' => [nil, contacts(:john).id],
      },
      created_at: Time.zone.parse('2024-01-01')
    )

    get admin_domain_version_path(create_version.id)

    assert_response :ok
    assert_includes response.body, 'ghost.test'
    assert_includes response.body, @registrar.name
    assert_no_match %r{href="#{admin_domain_path(deleted_item_id)}"}, response.body
    assert_no_match %r{admin_domain_version[^"]*current=1}, response.body
  end

  def test_show_update_version_of_deleted_domain
    deleted_item_id = next_unused_domain_id
    Version::DomainVersion.create!(
      item_type: 'Domain',
      item_id: deleted_item_id,
      event: 'create',
      whodunnit: users(:admin).id.to_s,
      object: nil,
      object_changes: {
        'name' => [nil, 'gone.test'],
        'registrar_id' => [nil, @registrar.id],
      },
      created_at: Time.zone.parse('2024-01-01')
    )
    update_version = Version::DomainVersion.create!(
      item_type: 'Domain',
      item_id: deleted_item_id,
      event: 'update',
      whodunnit: users(:admin).id.to_s,
      object: {
        'name' => 'gone.test',
        'registrar_id' => @registrar.id,
      },
      object_changes: {
        'statuses' => [[], ['serverHold']],
      },
      created_at: Time.zone.parse('2024-02-01')
    )

    get admin_domain_version_path(update_version.id)

    assert_response :ok
    assert_includes response.body, 'gone.test'
    assert_includes response.body, @registrar.name
    assert_no_match %r{href="#{admin_domain_path(deleted_item_id)}"}, response.body
  end

  def test_show_destroy_version_of_deleted_domain
    deleted_item_id = next_unused_domain_id
    Version::DomainVersion.create!(
      item_type: 'Domain',
      item_id: deleted_item_id,
      event: 'create',
      whodunnit: users(:admin).id.to_s,
      object: nil,
      object_changes: {
        'name' => [nil, 'bye.test'],
        'registrar_id' => [nil, @registrar.id],
      },
      created_at: Time.zone.parse('2024-01-01')
    )
    destroy_version = Version::DomainVersion.create!(
      item_type: 'Domain',
      item_id: deleted_item_id,
      event: 'destroy',
      whodunnit: users(:admin).id.to_s,
      object: {
        'name' => 'bye.test',
        'registrar_id' => @registrar.id,
      },
      object_changes: nil,
      created_at: Time.zone.parse('2024-03-01')
    )

    get admin_domain_version_path(destroy_version.id)

    assert_response :ok
    assert_includes response.body, 'bye.test'
  end

  private

  def next_unused_domain_id
    @next_unused_domain_id ||= Domain.maximum(:id).to_i +
                               Version::DomainVersion.maximum(:item_id).to_i +
                               1000
    @next_unused_domain_id += 1
  end
end
