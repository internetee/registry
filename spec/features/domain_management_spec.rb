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

  scenario 'User adds nameserver to domain' do
    d = Domain.first
    visit admin_domain_path(d)

    within('#nameservers') { click_on 'Add' }

    fill_in('Hostname', with: 'ns1.example.ee')
    fill_in('Ipv4', with: '192.168.1.1')
    fill_in('Ipv6', with: 'FE80:0000:0000:0000:0202:B3FF:FE1E:8329')

    click_on 'Save'

    expect(page).to have_text('Nameserver added!')

    within('#nameservers') do
      expect(page).to have_link('ns1.example.ee')
      expect(page).to have_text('192.168.1.1')
      expect(page).to have_text('FE80:0000:0000:0000:0202:B3FF:FE1E:8329')
    end
  end

  scenario 'User adds status to domain' do
    d = Domain.first
    visit admin_domain_path(d)

    within('#domain_statuses') { click_on 'Add' }

    fill_in('Description', with: 'All is well.')

    click_on 'Save'

    expect(page).to have_text('Status added!')

    within('#domain_statuses') do
      expect(page).to have_text('ok')
      expect(page).to have_text('All is well.')
    end
  end

  scenario 'User adds technical contact', js: true do
    d = Domain.first
    visit admin_domain_path(d)

    within('#tech_contacts') { click_on 'Add' }

    c = Contact.last
    fill_in('Tech contact', with: c.code, fill_options: { blur: false })
    # TODO: Wait for poltergeist to support blur option, then uncomment these lines:
    # expect(page).to have_text(c.code)
    # click_on(c.code)
    # expect(find_field('Tech contact').value).to eq(c.code)

    # temporary solution:
    page.execute_script("$('#contact_id').val('#{c.id}')")

    click_on 'Save'

    expect(page).to have_text('Contact added!')

    within('#tech_contacts') do
      expect(page).to have_link(c.name)
      expect(page).to have_text(c.email)
    end
  end
end
