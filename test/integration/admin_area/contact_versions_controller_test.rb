require 'test_helper'

class AdminAreaContactVersionsControllerIntegrationTest < ApplicationIntegrationTest
  setup do
    WebMock.allow_net_connect!
    sign_in users(:admin)

    @registrar = registrars(:bestnames)

    create_contact_with_history
  end

  def teardown
    delete_objects_once_done
    super
  end

  def test_search_endpoint_returns_expected_json
    expected_result = [{ 'id' => 1, 'display_key' => 'Test Name (test_code_775)' }]

    Version::ContactVersion.singleton_class.define_method(:search_by_query) { |*_args| [] } unless Version::ContactVersion.respond_to?(:search_by_query)

    Version::ContactVersion.stub :search_by_query, expected_result do
      get search_admin_contact_versions_path, params: { q: 'test_code_775' }
    end

    assert_response :ok
    json = JSON.parse(response.body)

    assert_equal expected_result, json
  end

  def test_created_at_lteq_filter_is_inclusive
    get admin_contact_versions_path(format: :csv),
        params: { q: { created_at_lteq: '2018-04-23' } }

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_includes response.body, 'test_code_775',
                    'Expected CSV export to contain the contact version created on the same day'
  end

  private

  def create_contact_with_history
    sql = <<-SQL.squish
      INSERT INTO contacts (id, name, code, email, auth_info, registrar_id)
      VALUES (775, 'Test Name', 'test_code_775', 'test@inbox.test', '8b4d462aa04194ca78840a', #{@registrar.id});

      INSERT INTO log_contacts (
        item_type, item_id, event, whodunnit, object, object_changes,
        created_at, session, children, ident_updated_at, uuid
      )
      VALUES (
        'Contact', 775, 'update', '1-AdminUser',
        '{"id": 775, "code": "test_code_775", "auth_info": "8b4d462aa04194ca78840a", "registrar_id": #{@registrar.id}}',
        '{"some_field": ["old", "new"]}',
        '2018-04-23 15:50:48.113491', '2018-04-23 12:44:56', '{"legal_documents":[null]}', NULL, NULL
      );
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  def delete_objects_once_done
    ActiveRecord::Base.connection.execute('DELETE FROM log_contacts WHERE item_id = 775')
    ActiveRecord::Base.connection.execute('DELETE FROM contacts WHERE id = 775')
  end
end
