require 'application_system_test_case'

class AdminAreaZonesTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    @zone = dns_zones(:one)
  end

  def test_creates_new_zone_with_required_attributes
    origin = 'com.test'
    assert_nil DNS::Zone.find_by(origin: origin)

    visit admin_zones_url
    click_on 'New zone'

    fill_in 'Origin', with: origin
    fill_in 'Ttl', with: '1'
    fill_in 'Refresh', with: '1'
    fill_in 'Retry', with: '1'
    fill_in 'Expire', with: '1'
    fill_in 'Minimum ttl', with: '1'
    fill_in 'Email', with: 'new.registry.test'
    fill_in 'Master nameserver', with: 'any.test'
    click_on 'Create zone'

    assert_text 'Zone has been created'
    assert_text origin
  end

  def test_changes_zone
    new_email = 'new@registry.test'
    assert_not_equal new_email, @zone.email

    visit admin_zones_url
    click_on 'admin-edit-zone-btn'
    fill_in 'Email', with: new_email
    click_on 'Update zone'

    assert_text 'Zone has been updated'
  end

  def test_origin_is_not_editable
    visit edit_admin_zone_url(@zone)
    assert_no_field 'Origin'
  end
end
