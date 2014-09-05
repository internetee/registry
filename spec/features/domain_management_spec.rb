require 'rails_helper'

feature 'Domain management', type: :feature do
  background do
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
end
