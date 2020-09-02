require 'application_system_test_case'

class AdminAreaPricesTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    @price = billing_prices(:create_one_month)
  end

  def test_adds_new_price_with_required_attributes
    effective_date = Date.parse('2010-07-06')
    assert_nil Billing::Price.find_by(valid_from: effective_date)

    visit admin_prices_url
    click_on 'New price'

    select dns_zones(:one).origin, from: 'Zone'
    select Billing::Price.operation_categories.first, from: 'Operation category'
    select '3 months', from: 'Duration'
    fill_in 'Price', with: '1'
    fill_in 'Valid from', with: effective_date
    click_on 'Create price'

    assert_text 'Price has been created'
    assert_text I18n.localize(effective_date)
  end

  def test_changes_price
    new_effective_date = Date.parse('2010-07-06')
    assert_not_equal new_effective_date, @price.valid_from

    visit admin_prices_url
    find('.edit-price-btn').click
    fill_in 'Valid from', with: new_effective_date
    click_on 'Update price'

    assert_text 'Price has been updated'
    assert_text I18n.localize(new_effective_date)
  end

  def test_expires_price
    visit admin_prices_url
    find('.edit-price-btn').click
    click_on 'Expire'

    assert_text 'Price has been expired'
  end
end
