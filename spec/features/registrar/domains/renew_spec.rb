require 'rails_helper'

RSpec.feature 'Renew domain in registrar area' do
  given!(:registrar) { create(:registrar) }
  given!(:user) { create(:api_user, registrar: registrar) }
  given!(:domain) { create(:domain, registrar: registrar) }

  background do
    sign_in_to_registrar_area(user: user)
  end

  it 'has default period' do
    visit registrar_domains_path
    click_link_or_button t('renew')

    expect(page).to have_field('period', with: Depp::Domain.default_period)
  end
end
