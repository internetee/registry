require 'rails_helper'

feature 'Setting management' do
  background { Fabricate(:domain_validation_setting_group) }

  scenario 'User changes a setting', js: true do
    visit root_path

    # This ensures javascript works correctly
    expect(page).to have_no_link 'Setting groups'
    click_on 'Settings'
    expect(page).to have_link 'Setting groups'

    click_on 'Setting groups'
    expect(page).to have_text('Domain validation')
    click_on 'Edit settings'
    expect(page).to have_text('Nameserver minimum count')
    expect(page).to have_text('Nameserver maximum count')

    val_min = find_field('Nameserver minimum count').value
    val_max = find_field('Nameserver maximum count').value

    expect(val_min).to eq('1')
    expect(val_max).to eq('13')

    fill_in('Nameserver minimum count', with: '3')
    fill_in('Nameserver maximum count', with: '10')

    click_on 'Save'

    val_min = find_field('Nameserver minimum count').value
    val_max = find_field('Nameserver maximum count').value

    expect(val_min).to eq('3')
    expect(val_max).to eq('10')
  end
end
