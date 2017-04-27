require 'rails_helper'

RSpec.feature 'Deleting price in admin area', settings: false do
  given!(:price) { create(:price) }

  background do
    sign_in_to_admin_area
  end

  scenario 'deletes price' do
    visit admin_prices_url
    open_form
    click_link_or_button t('admin.billing.prices.edit.delete_btn')

    expect(page).to have_text(t('admin.billing.prices.destroy.destroyed'))
  end

  private

  def open_form
    click_link_or_button 'admin-edit-price-btn'
  end
end
