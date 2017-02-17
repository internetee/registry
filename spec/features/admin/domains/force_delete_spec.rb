require 'rails_helper'

RSpec.feature 'Force delete' do
  context 'when domain has no force delete procedure' do
    given!(:domain) { create(:domain_without_force_delete) }

    scenario 'schedule' do
      sign_in_to_admin_area

      visit edit_admin_domain_url(domain)
      click_link_or_button 'Force delete domain'

      expect(page).to have_text('Force delete procedure has been scheduled')
    end
  end

  context 'when domain has force delete procedure' do
    given!(:domain) { create(:domain_without_force_delete) }

    background do
      domain.schedule_force_delete
    end

    scenario 'cancel' do
      sign_in_to_admin_area

      visit edit_admin_domain_url(domain)
      click_link_or_button 'Cancel force delete'

      expect(page).to have_text('Force delete procedure has been cancelled')
    end
  end
end
