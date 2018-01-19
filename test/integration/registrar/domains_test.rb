require 'test_helper'

class RegistrarDomainsTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:api)
  end

  def test_downloads_domain_list_as_csv
    expected_csv = <<-CSV.strip_heredoc
      Domain,Auth info,Registrant name,Registrant code,Date of expiry
      library.test,45118f5,Acme Ltd,acme-ltd-001,2010-07-05
      shop.test,65078d5,John,john-001,2010-07-05
      airport.test,55438j5,John,john-001,2010-07-05
    CSV

    visit registrar_domains_url
    click_button 'Download as CSV'
    assert_equal expected_csv, page.body
  end
end
