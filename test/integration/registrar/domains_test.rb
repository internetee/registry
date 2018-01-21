require 'test_helper'

class RegistrarDomainsTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:api)
  end

  def test_downloads_domain_list_as_csv
    expected_csv = <<-CSV.strip_heredoc
      Domain,Transfer code,Registrant name,Registrant code,Date of expiry
      library.test,45118f5,Acme Ltd,acme-ltd-001,2010-07-05
      shop.test,65078d5,John,john-001,2010-07-05
      airport.test,55438j5,John,john-001,2010-07-05
    CSV

    visit registrar_domains_url
    click_button 'Download as CSV'
    assert_equal expected_csv, page.body
  end

  def test_transfers_domain
    travel_to Time.zone.parse('2010-07-05 10:30:00')

    visit registrar_domains_url
    click_link 'Transfer'
    fill_in 'Name', with: 'shop.test'
    fill_in 'Password', with: '65078d5'
    click_button 'Transfer'

    assert_text 'Transfer requested at: 2010-07-05 10:30:00'
  end
end
