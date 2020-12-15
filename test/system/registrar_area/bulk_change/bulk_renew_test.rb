require 'application_system_test_case'

class BulkRenewTest < ApplicationSystemTestCase
  setup do
    @registrar = users(:api_bestnames).registrar
    @price = billing_prices(:renew_one_year)
  end

  def test_shows_domain_list
    sign_in users(:api_bestnames)
    travel_to Time.zone.parse('2010-07-05 10:30')

    visit new_registrar_bulk_change_url
    click_link('Bulk renew')
    assert_text 'Current balance'
    page.has_css?('#registrar_balance', text:
      ApplicationController.helpers.number_to_currency(@registrar.balance))

    select '1 year', from: 'Period'
    click_button 'Filter'

    @registrar.domains.pluck(:name).each do |domain_name|
      assert_text domain_name
    end
  end

  def test_makes_bulk_renew
    sign_in users(:api_bestnames)
    travel_to Time.zone.parse('2010-07-05 10:30')

    visit new_registrar_bulk_change_url
    click_link('Bulk renew')
    select '1 year', from: 'Period'
    click_button 'Filter'
    click_button 'Renew'

    assert_text 'invalid.test'
    assert_no_text 'shop.test'
  end

  def test_bulk_renew_checks_balance
    sign_in users(:api_bestnames)
    @price.update(price_cents: 99999999)
    travel_to Time.zone.parse('2010-07-05 10:30')

    visit new_registrar_bulk_change_url
    click_link('Bulk renew')
    select '1 year', from: 'Period'
    click_button 'Filter'
    click_button 'Renew'

    assert_text 'Not enough funds for renew domains'

  end
end
