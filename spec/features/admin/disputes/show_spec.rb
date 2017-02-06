require 'rails_helper'

RSpec.feature 'Dispute overview' do
  given!(:domain) { create(:domain, name: 'test.com') }
  given!(:dispute) { create(:dispute, domain_name: 'test.com') }

  scenario 'dispute overview' do
    sign_in_to_admin_area

    visit admin_dispute_url(dispute)

    expect(page).to have_text('test.com')
  end
end
