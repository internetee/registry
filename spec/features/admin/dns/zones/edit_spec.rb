require 'rails_helper'

RSpec.feature 'Editing zone in admin area', settings: false do
  given!(:zone) { create(:zone) }

  background do
    sign_in_to_admin_area
  end

  scenario 'updates zone' do
    open_list
    open_form
    submit_form

    expect(page).to have_text(t('admin.dns.zones.update.updated'))
  end

  def open_list
    click_link_or_button t('admin.menu.zones')
  end

  def open_form
    click_link_or_button t('admin.dns.zones.zone.edit_btn')
  end

  def submit_form
    click_link_or_button t('admin.dns.zones.form.update_btn')
  end
end
