require 'application_system_test_case'

class DomainsCsvTest < ApplicationSystemTestCase
  setup { sign_in users(:admin) }

  def test_download_domains_list_as_csv
    travel_to Time.zone.parse('2010-07-05 10:30')
    Domain.all.each do |domain|
      domain.created_at = Time.zone.now
      domain.save(:validate => false)
    end

    visit admin_domains_url
    click_link('CSV')

    assert_equal "attachment; filename=\"domains_#{Time.zone.now.to_formatted_s(:number)}.csv\"; filename*=UTF-8''domains_#{Time.zone.now.to_formatted_s(:number)}.csv", response_headers['Content-Disposition']
    assert_equal file_fixture('domains.csv').read, page.body
  end
end
