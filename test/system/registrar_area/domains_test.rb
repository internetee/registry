require 'application_system_test_case'

class RegistrarDomainsTest < ApplicationSystemTestCase
  setup do
    @registrar = users(:api_bestnames).registrar
    @price = billing_prices(:renew_one_year)
  end

  def test_downloads_domain_list_as_csv
    sign_in users(:api_bestnames)
    travel_to Time.zone.parse('2010-07-05 10:30')

    expected_csv = <<-CSV.strip_heredoc
      Domain,Transfer code,Registrant name,Registrant code,Date of expiry
      library.test,45118f5,Acme Ltd,acme-ltd-001,2010-07-05
      shop.test,65078d5,John,john-001,2010-07-05
      invalid.test,1438d6,any,invalid,2010-07-05
      airport.test,55438j5,John,john-001,2010-07-05
    CSV

    visit registrar_domains_url
    click_button 'Download CSV'
    assert_equal "attachment; filename=\"Domains_2010-07-05_10.30.csv\"; filename*=UTF-8''Domains_2010-07-05_10.30.csv", response_headers['Content-Disposition']
    assert_equal expected_csv, page.body
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
