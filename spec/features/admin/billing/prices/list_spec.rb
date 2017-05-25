require 'rails_helper'

RSpec.feature 'Viewing prices in admin area', settings: false do
  given!(:unexpired_price) { create(:unexpired_price) }
  given!(:expired_price) { create(:expired_price) }

  background do
    sign_in_to_admin_area
  end

  describe 'search' do
    context 'when validity is not selected' do
      scenario 'shows unexpired prices' do
        visit admin_prices_path
        expect(page).to have_css('.price', count: 1)
      end
    end

    context 'when validity is given' do
      scenario 'filters by given validity' do
        visit admin_prices_path
        select 'unexpired', from: 'search_validity'
        submit_search_form

        expect(page).to have_css('.price', count: 1)
      end
    end

    def submit_search_form
      find('.price-search-form-search-btn').click
    end
  end
end
