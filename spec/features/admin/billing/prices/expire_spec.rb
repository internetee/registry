require 'rails_helper'

RSpec.feature 'Expiring price in admin area', settings: false do
  given!(:price) { create(:unexpired_price) }

  background do
    sign_in_to_admin_area
  end

  scenario 'expires price' do
    visit admin_prices_path
    open_edit_form
    expire

    expect(page).to have_text(t('admin.billing.prices.expire.expired'))
  end

  def open_edit_form
    find('.edit-price-btn').click
  end

  def expire
    click_link_or_button t('admin.billing.prices.edit.expire_btn')
  end
end
