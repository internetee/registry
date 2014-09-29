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

  scenario 'Registrar requests transfer on own domain', js: true do
    sign_in zone_user
    click_on 'Domains'
    click_on 'Domain transfers list'
    click_on 'Request domain transfer'

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

  scenario 'Other registrar requests transfer with 0 wait time' do
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

  scenario 'Other registrar requests transfer with 1 wait time' do
    s = Setting.find_by(code: 'transfer_wait_time')
    s.value = 1
    s.save

    sign_in elkdata_user
    d = Domain.first
    visit client_domains_path
    expect(page).to_not have_link(d.name)

    visit new_client_domain_transfer_path
    fill_in 'Domain name', with: d.name
    fill_in 'Domain password', with: d.auth_info
    click_on 'Request domain transfer'

    expect(page).to have_text('Domain transfer requested!')
    expect(page).to have_text('pending')

    visit new_client_domain_transfer_path
    fill_in 'Domain name', with: d.name
    fill_in 'Domain password', with: d.auth_info
    click_on 'Request domain transfer'

    expect(page).to have_text('Domain transfer requested!')
    expect(page).to have_text('pending')

    visit client_domains_path
    expect(page).to_not have_link(d.name)
  end

  scenario 'Domain owner approves request' do
    s = Setting.find_by(code: 'transfer_wait_time')
    s.value = 1
    s.save

    d = Domain.first
    d.domain_transfers.create(
      status: DomainTransfer::PENDING,
      transfer_requested_at: Time.zone.now,
      transfer_to: elkdata,
      transfer_from: zone
    )

    sign_in elkdata_user
    visit new_client_domain_transfer_path
    fill_in 'Domain name', with: d.name
    fill_in 'Domain password', with: d.auth_info
    click_on 'Request domain transfer'

    expect(page).to have_text('Domain transfer requested!')
    expect(page).to_not have_button('Approve')

    sign_in zone_user

    visit new_client_domain_transfer_path
    fill_in 'Domain name', with: d.name
    fill_in 'Domain password', with: d.auth_info
    click_on 'Request domain transfer'

    expect(page).to have_link('Approve')

    click_on 'Approve'
    expect(page).to have_text('Domain transfer approved!')
    expect(page).to have_text('clientApproved')

    sign_in elkdata_user
    visit client_domains_path
    expect(page).to have_link(d.name)
  end
end
