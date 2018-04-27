require 'test_helper'

class AdminContactsTest < ActionDispatch::IntegrationTest
  def setup
    super

    @contact = contacts(:william)
    login_as users(:admin)
  end

  def teardown
    super
  end

  def test_display_list
    visit admin_contacts_path

    assert_text('william-001')
    assert_text('william-002')
    assert_text('acme-ltd-001')
  end

  def test_display_details
    visit admin_contact_path(@contact)

    assert_text('Street Main Street City New York Postcode 12345 ' \
                'State New York Country United States of America')
  end
end
