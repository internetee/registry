require 'rails_helper'

RSpec.feature 'Admin settings' do
  background do
    sign_in_to_admin_area
  end

  it 'saves settings' do
    visit admin_settings_path
    click_link_or_button 'Save'
    expect(page).to have_text(t('admin.settings.create.saved'))
  end
end
