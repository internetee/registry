require 'rails_helper'

feature 'Sessions', type: :feature do
  let(:elkdata) { Fabricate(:registrar, { name: 'Elkdata', reg_no: '123' }) }
  let(:zone) { Fabricate(:registrar) }

  background do
    create_settings
    Fabricate(:user, registrar: nil, identity_code: '37810013261')
    Fabricate(:user, registrar: zone, username: 'zone', admin: false, identity_code: '37810013087')
    Fabricate.times(2, :domain, registrar: zone)
    Fabricate.times(2, :domain, registrar: elkdata)
  end

  scenario 'Admin logs in' do
    visit root_path
    expect(page).to have_button('ID card (gitlab)')
    expect(page).to have_button('ID card (zone)')

    click_on 'ID card (gitlab)'
    expect(page).to have_text('Welcome!')

    uri = URI.parse(current_url)
    expect(uri.path).to eq(admin_root_path)

    expect(page).to have_link('Elkdata', count: 2)
    expect(page).to have_link('Zone Media OÜ', count: 2)
  end

  scenario 'Client logs in' do
    visit root_path

    click_on 'ID card (zone)'
    expect(page).to have_text('Welcome!')

    uri = URI.parse(current_url)
    expect(uri.path).to eq(client_root_path)

    zone.domains.pluck(:name).each do |name|
      expect(page).to have_link(name)
    end

    elkdata.domains.pluck(:name).each do |name|
      expect(page).to_not have_link(name)
    end
  end
end
