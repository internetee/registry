require 'application_system_test_case'

class DomainVersionsTest < ApplicationSystemTestCase
  def setup
    super

    @registrar = registrars(:bestnames)
    @domain = domains(:shop)

    create_domain_with_history
    sign_in users(:admin)
  end

  def teardown
    super

    delete_objects_once_done
  end

  def create_domain_with_history
    sql = <<-SQL.squish
      INSERT INTO contacts (id, name, code, email, auth_info, registrar_id)
      VALUES (54, 'test_code', 'test_name', 'test@inbox.test', '8b4d462aa04194ca78840a', #{@registrar.id});

      INSERT INTO domains (id, name, name_puny, name_dirty, registrar_id, valid_to, registrant_id,
      transfer_code)
      VALUES (54, 'any.test', 'any.test', 'any.test', #{@registrar.id}, '2018-06-23T12:14:02.732+03:00', 54, 'transfer_code');

      INSERT INTO log_domains (item_type, item_id, event, whodunnit, object,
      object_changes, created_at, session, children)
      VALUES ('Domain', 54, 'update', '1-AdminUser',
      '{"id": 54, "registrar_id": #{@registrar.id}, "valid_to": "2018-07-23T12:14:05.583+03:00", "registrant_id": 54, "transfer_code": "transfer_code", "valid_from": "2017-07-23T12:14:05.583+03:00"}',
      '{"foo": "bar", "other_made_up_field": "value"}',
      '2018-04-23 15:50:48.113491', '2018-04-23 12:44:56',
      '{"null_fracdmin_contacts":[108],"tech_contacts":[109],"nameservers":[],"dnskeys":[],"legal_documents":[null],"registrant":[1]}'
      )
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def delete_objects_once_done
    ActiveRecord::Base.connection.execute('DELETE FROM log_domains where item_id = 54')
  end

  def test_removed_fields_are_not_causing_errors_in_index_view
    assert_equal 'Best Names', @registrar.name

    visit admin_domain_versions_path

    assert_text 'Best Names'
    assert_text 'Best Names update 23.04.18, 18:50'
  end

  def test_removed_fields_are_not_causing_errors_in_details_view
    assert_equal 'Best Names', @registrar.name

    version_id = Domain.find(54).versions.last
    visit admin_domain_version_path(version_id)

    assert_text 'Best Names'
    assert_text '23.04.18, 18:50 update 1-AdminUser'
  end

  def test_search_registrant_param
    visit admin_domain_versions_path
    fill_in 'Registrant', with: @domain.registrant, match: :first
    find('.btn.btn-primary').click

    assert_equal current_url,
      'http://www.example.com/admin/domain_versions?q[name]=&q[registrant]=John&q[registrar]=&q[event]=&results_per_page='
  end

  def test_search_registrar_param
    visit admin_domain_versions_path
    find('#_q_registrar').find(:option, @domain.registrar).select_option
    find('.btn.btn-primary').click

    assert_equal current_url,
      'http://www.example.com/admin/domain_versions?q[name]=&q[registrant]=&q[registrar]=Best+Names&q[event]=&results_per_page='
  end

  def test_search_name_param
    visit admin_domain_versions_path
    fill_in 'Name', with: @domain.name, match: :first
    find('.btn.btn-primary').click

    assert_equal current_url,
      'http://www.example.com/admin/domain_versions?q[name]=shop.test&q[registrant]=&q[registrar]=&q[event]=&results_per_page='
  end

  def test_download_domain_history
    now = Time.zone.parse('2010-07-05 08:00')
    travel_to now

    get admin_domain_versions_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_equal %(attachment; filename="domain_history_#{Time.zone.now.to_formatted_s(:number)}.csv"; filename*=UTF-8''domain_history_#{Time.zone.now.to_formatted_s(:number)}.csv),
                 response.headers['Content-Disposition']
    assert_not_empty response.body
  end

  def test_search_event_param
    # TODO
  end
end
