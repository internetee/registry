require 'rails_helper'

RSpec.feature 'Deleting zone in admin area', settings: false do
  given!(:zone) { create(:zone) }

  background do
    sign_in_to_admin_area
  end

  scenario 'deletes zone' do
    visit edit_admin_zone_url(zone)
    click_link_or_button t('admin.dns.zones.edit.delete_btn')

    expect(page).to have_text(t('admin.dns.zones.destroy.destroyed'))
  end
end
