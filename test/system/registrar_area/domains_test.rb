require 'test_helper'

class RegistrarDomainsTest < ApplicationSystemTestCase
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
    click_button 'Download as CSV'
    assert_equal 'attachment; filename="Domains_2010-07-05_10.30.csv"', response_headers['Content-Disposition']
    assert_equal expected_csv, page.body
  end
end
