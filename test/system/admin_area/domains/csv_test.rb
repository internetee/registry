require 'application_system_test_case'

class AdminAreaCsvTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_downloads_domain_list_as_csv
    search_params = {"valid_to_lteq"=>nil}
    expected_csv = Domain.includes(:registrar, :registrant).search(search_params).result.to_csv

    travel_to Time.zone.parse('2010-07-05 10:30')
    visit admin_domains_url
    click_link('CSV')
    assert_equal "attachment; filename=\"domains_#{Time.zone.now.to_formatted_s(:number)}.csv\"; filename*=UTF-8''domains_#{Time.zone.now.to_formatted_s(:number)}.csv", response_headers['Content-Disposition']
    assert_equal expected_csv, page.body
  end
end
