require 'application_system_test_case'

class ContactVersionsTest < ApplicationSystemTestCase
  def setup
    super

    @registrar = registrars(:bestnames)

    create_contact_with_history
    sign_in users(:admin)
  end

  def teardown
    super

    delete_objects_once_done
  end

  def create_contact_with_history
    sql = <<-SQL.squish
      INSERT INTO contacts (id, code, email, auth_info, registrar_id)
      VALUES (75, 'test_code', 'test@inbox.test', '8b4d462aa04194ca78840a', #{@registrar.id});

      INSERT INTO log_contacts (item_type, item_id, event, whodunnit, object,
      object_changes, created_at, session, children, ident_updated_at, uuid)
      VALUES ('Contact', 75, 'update', '1-AdminUser',
      '{"id": 75, "code": "test_code", "auth_info": "8b4d462aa04194ca78840a", "registrar_id": #{@registrar.id}, "old_field": "value"}',
      '{"other_made_up_field": "value"}',
      '2018-04-23 15:50:48.113491', '2018-04-23 12:44:56',
      '{"legal_documents":[null]}', null, null
      )
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  def delete_objects_once_done
    ActiveRecord::Base.connection.execute('DELETE from log_contacts where item_id = 75')
  end

  def test_removed_fields_are_not_causing_errors_in_index_view
    assert_equal 'Best Names', @registrar.name

    visit admin_contact_versions_path
    assert_text 'Best Names'
    assert_text 'update 23.04.18, 18:50'
  end

  def test_removed_fields_are_not_causing_errors_in_details_view
    assert_equal 'Best Names', @registrar.name

    version_id = Contact.find(75).versions.last
    visit admin_contact_version_path(version_id)

    assert_text 'Best Names'
    assert_text '23.04.18, 18:50 update 1-AdminUser'
  end
end