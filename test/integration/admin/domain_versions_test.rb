require 'test_helper'

class DomainVersionsTest < ActionDispatch::IntegrationTest
  def setup
    super

    create_domain_with_history
    sign_in users(:admin)
  end

  def teardown
    super

    delete_objects_once_done
  end

  def create_domain_with_history
    sql = <<-SQL.squish
      INSERT INTO registrars (id, name, reg_no, email, country_code, code,
      accounting_customer_code, language)
      VALUES (54, 'test_registrar', 'test123', 'test@test.com', 'EE', 'TEST123',
      'test123', 'en');

      INSERT INTO contacts (id, name, code, auth_info, registrar_id)
      VALUES (54, 'test_name', 'test_code', '8b4d462aa04194ca78840a', 54);

      INSERT INTO domains (id, registrar_id, valid_to, registrant_id,
      transfer_code)
      VALUES (54, 54, '2018-06-23T12:14:02.732+03:00', 54, 'transfer_code');

      INSERT INTO log_domains (item_type, item_id, event, whodunnit, object,
      object_changes, created_at, nameserver_ids, tech_contact_ids,
      admin_contact_ids, session, children)
      VALUES ('Domain', 54, 'update', '1-AdminUser',
      '{"id": 54, "registrar_id": 54, "valid_to": "2018-07-23T12:14:05.583+03:00", "registrant_id": 54, "transfer_code": "transfer_code", "valid_from": "2017-07-23T12:14:05.583+03:00"}',
      '{"foo": "bar", "other_made_up_field": "value"}',
      '2018-04-23 15:50:48.113491', '{}', '{}', '{}', '2018-04-23 12:44:56',
      '{"null_fracdmin_contacts":[108],"tech_contacts":[109],"nameservers":[],"dnskeys":[],"legal_documents":[null],"registrant":[1]}'
      )
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def delete_objects_once_done
    ActiveRecord::Base.connection.execute('DELETE FROM log_domains where item_id = 54')
    Domain.destroy_all
    Contact.destroy_all
    Registrar.destroy_all
  end

  def test_removed_fields_are_not_causing_errors_in_index_view
    visit admin_domain_versions_path

    assert_text 'test_registrar'
    assert_text 'test_registrar update 23.04.18, 18:50'
  end

  def test_removed_fields_are_not_causing_errors_in_details_view
    version_id = Domain.find(54).versions.last
    visit admin_domain_version_path(version_id)

    assert_text 'test_registrar'
    assert_text '23.04.18, 18:50 update 1-AdminUser'
  end
end
