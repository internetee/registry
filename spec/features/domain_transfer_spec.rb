require 'rails_helper'

feature 'Domain transfer', type: :feature do
  let(:elkdata) { Fabricate(:registrar, { name: 'Elkdata', reg_no: '123' }) }
  let(:zone) { Fabricate(:registrar) }
  let(:zone_user) { Fabricate(:user, registrar: zone, username: 'zone', admin: false) }
  let(:elkdata_user) { Fabricate(:user, registrar: elkdata, username: 'elkdata', admin: false) }

  background do
    Fabricate(:domain_validation_setting_group)
    Fabricate(:domain_general_setting_group)
    Fabricate(:domain, registrar: zone)
  end

  scenario 'when registrar requests transfer on own domain', js: true do
    sign_in zone_user
    click_on 'Domains'
    click_on 'Transfer domain'

    fill_in 'Domain name', with: 'false'
    click_on 'Request domain transfer'
    expect(page).to have_text('Domain was not found!')

    d = Domain.first
    fill_in 'Domain name', with: d.name
    click_on 'Request domain transfer'
    expect(page).to have_text('Password invalid!')

    fill_in 'Domain password', with: d.auth_info
    click_on 'Request domain transfer'

    expect(page).to have_text('Domain already belongs to the querying registrar')
  end

  scenario 'when other registrar requests transfer' do
    sign_in elkdata_user
    d = Domain.first
    visit client_domains_path
    expect(page).to_not have_link(d.name)

    visit new_client_domain_transfer_path
    fill_in 'Domain name', with: d.name
    fill_in 'Domain password', with: d.auth_info
    click_on 'Request domain transfer'

    expect(page).to have_text('Domain transfer approved!')
    expect(page).to have_text('serverApproved')

    visit client_domains_path
    expect(page).to have_link(d.name)
  end
end
