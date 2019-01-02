require 'test_helper'

class AdminAreaReservedDomainsNewTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_creates_new_with_requires_attributes
    visit admin_reserved_domains_url
    click_on 'New reserved domain'
    fill_in 'Name', with: 'reserved-new.test'

    assert_difference 'ReservedDomain.count' do
      click_link_or_button 'Save'
    end
    assert_equal 'reserved-new.test', ReservedDomain.last.name
    assert_current_path admin_reserved_domains_url
    assert_text 'Domain added!'
  end

  def test_generates_password_automatically_when_left_blank
    visit new_admin_reserved_domain_url
    fill_in 'Name', with: 'some.test'

    assert_difference 'ReservedDomain.count' do
      click_link_or_button 'Save'
    end
    assert_not_empty ReservedDomain.last.password
  end

  def test_honors_custom_password
    visit new_admin_reserved_domain_url
    fill_in 'Name', with: 'some.test'
    fill_in 'Password', with: 'reserved-123'

    assert_difference 'ReservedDomain.count' do
      click_link_or_button 'Save'
    end
    assert_equal 'reserved-123', ReservedDomain.last.password
  end
end
