require 'rails_helper'

RSpec.feature 'New zone in admin area', settings: false do
  background do
    sign_in_to_admin_area
  end

  scenario 'it creates new zone' do
    open_list
    open_form
    fill_form
    submit_form

    expect(page).to have_text(t('admin.dns.zones.create.created'))
  end

  def open_list
    click_link_or_button t('admin.menu.zones')
  end

  def open_form
    click_link_or_button t('admin.dns.zones.index.new_btn')
  end

  def fill_form
    fill_in 'zone_origin', with: 'test'
    fill_in 'zone_ttl', with: '1'
    fill_in 'zone_refresh', with: '1'
    fill_in 'zone_retry', with: '1'
    fill_in 'zone_expire', with: '1'
    fill_in 'zone_minimum_ttl', with: '1'
    fill_in 'zone_email', with: 'test@test.com'
    fill_in 'zone_master_nameserver', with: 'test.test'
  end

  def submit_form
    click_link_or_button t('admin.dns.zones.form.create_btn')
  end
end
