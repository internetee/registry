require 'rails_helper'

RSpec.feature 'New domain in registrar area', settings: false do
  background do
    sign_in_to_registrar_area
  end

  it 'has default period' do
    visit registrar_domains_path
    click_link_or_button t('new')

    expect(page).to have_field('domain_period', with: Depp::Domain.default_period)
  end
end
