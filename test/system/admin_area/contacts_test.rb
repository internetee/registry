require 'application_system_test_case'

class AdminContactsTest < ApplicationSystemTestCase
  def setup
    super

    @contact = contacts(:william)
    sign_in users(:admin)
  end

  def test_update_contact
    visit admin_contact_path(@contact.id)
    assert_text "#{@contact.name}"

    click_on 'Edit statuses'
    assert_text "Edit: #{@contact.name}"

    click_on 'Save'
    assert_text 'Contact updated'
  end

  def test_display_death_registry_data
    @contact.update_columns(death_date: Date.new(2026, 1, 1),
                            death_registry_checked_at: Time.zone.parse('2026-10-19 10:00'))

    visit admin_contact_path(@contact)

    assert_text 'Death date'
    assert_text 'Death registry checked'
  end

  def test_filters_deceased_contacts
    @contact.update_columns(death_date: Date.new(2026, 1, 1))

    visit admin_contacts_path
    select 'Deceased', from: 'death_registry'
    find('.btn.btn-primary').click

    assert_text @contact.code
    assert_no_text contacts(:acme_ltd).code
  end

  def test_filters_contacts_not_checked_against_death_registry
    Contact.update_all(death_registry_checked_at: Time.zone.now)
    @contact.update_columns(death_registry_checked_at: nil)

    visit admin_contacts_path(death_registry: 'not_checked')

    assert_text @contact.code
    assert_no_text contacts(:acme_ltd).code
  end

  def test_display_list
    visit admin_contacts_path

    assert_text('william-001')
    assert_text('william-002')
    assert_text('acme-ltd-001')
    assert_text(@contact.name)
    assert_text(@contact.code.to_s)
    assert_text(@contact.email)
    assert_text(@contact.registrar.name)
  end

  def test_display_details
    assert_nothing_raised do
      visit admin_contact_path(@contact)
    end

    assert_text('Street Main Street City New York Postcode 12345 ' \
                'State New York State Country United States of America')
  end

  def test_download_contacts
    now = Time.zone.parse('2010-07-05 08:00')
    travel_to now

    get admin_contacts_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_equal %(attachment; filename="contacts_#{Time.zone.now.to_formatted_s(:number)}.csv"; filename*=UTF-8''contacts_#{Time.zone.now.to_formatted_s(:number)}.csv),
                 response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
