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

    req_body = { domains: ["shop.test", "airport.test", "library.test", "invalid.test"], renew_period: "1y" }
    stub_request(:post, "#{ENV['repp_url']}domains/renew/bulk").with(body: req_body)
    .to_return(status: 400, body: {
        code: 2304,
        message: "Domain renew error for invalid.test",
        data: {}
      }.to_json)

    visit new_registrar_bulk_change_url
    click_link('Bulk renew')
    select '1 year', from: 'Period'
    click_button 'Filter'
    click_button 'Renew'

    assert_text 'Domain renew error for invalid.test'
  end

  def test_bulk_renew_checks_balance
    sign_in users(:api_bestnames)
    @price.update(price_cents: 99999999)
    travel_to Time.zone.parse('2010-07-05 10:30')

    req_body = { domains: ["shop.test", "airport.test", "library.test", "invalid.test"], renew_period: "1y" }
    stub_request(:post, "#{ENV['repp_url']}domains/renew/bulk").with(body: req_body)
    .to_return(status: 400, body: {
        code: 2304,
        message: "Not enough funds for renew domains",
        data: {}
      }.to_json)

    visit new_registrar_bulk_change_url
    click_link('Bulk renew')
    select '1 year', from: 'Period'
    click_button 'Filter'
    click_button 'Renew'

    assert_text 'Not enough funds for renew domains'

  end
end
