require 'application_system_test_case'

class BulkRenewTest < ApplicationSystemTestCase
  setup do
    @registrar = users(:api_bestnames).registrar
    @price = billing_prices(:renew_one_year)
  end

  def test_mass_renewal
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
end
