require 'rails_helper'

feature 'Domain management', type: :feature do
  background do
    Fabricate(:registrar)
    Fabricate(:domain_validation_setting_group)
    Fabricate.times(4, :domain)
  end

  scenario 'User sees domains', js: true do
    visit root_path
    click_on 'Domains'

    Domain.all.each do |x|
      expect(page).to have_link(x)
      expect(page).to have_link(x.registrar)
      expect(page).to have_link(x.owner_contact)
    end
  end

  scenario 'User adds a domain', js: true do
    visit admin_domains_path
    click_on 'Add'
    fill_in('Domain name', with: 'example.ee')
    fill_in('Period', with: 1)
    fill_in('Registrar', with: 'zone', fill_options: { blur: false })
    # TODO: Wait for poltergeist to support blur option, then uncomment these lines:
    # expect(page).to have_text('Zone Media OÜ (10577829)')
    # click_on('Zone Media OÜ (10577829)')
    # expect(find_field('Registrar').value).to eq('Zone Media OÜ (10577829)')

    # temporary solution:

    page.execute_script("$('#domain_registrar_id').val('1')")

    c = Contact.first

    fill_in('Registrant', with: c.code, fill_options: { blur: false })
    # TODO: Wait for poltergeist to support blur option, then uncomment these lines:
    # expect(page).to have_text(c.code)
    # click_on(c.code)
    # expect(find_field('Registrar').value).to eq(c.code)

    # temporary solution:
    page.execute_script("$('#domain_owner_contact_id').val('1')")

    click_on('Save')

    expect(page).to have_text('Domain details')
    expect(page).to have_text('example.ee')
    expect(page).to have_link('Zone Media OÜ')
    expect(page).to have_link(c.name, count: 3)
    expect(page).to have_text(c.code)
    expect(page).to have_text(c.ident)
    expect(page).to have_text(c.email)
    expect(page).to have_text(c.phone)
    expect(page).to have_text('Nameservers count must be between 1-13')
  end
end
