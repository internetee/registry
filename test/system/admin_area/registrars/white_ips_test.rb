require 'application_system_test_case'

class AdminRegistrarsWhiteIpsSystemTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_downloads_whitelisted_ips_list_as_csv
    travel_to Time.zone.parse('2010-07-05 10:30')
    registrar = registrars(:bestnames)
    white_ips = registrar.white_ips
    white_ips.each do |ip|
      ip.created_at = Time.zone.now
      ip.updated_at = Time.zone.now
      ip.save(validate: false)
    end

    visit admin_registrar_path(registrar)
    within('.white_ips') do
      click_on 'Export to CSV'
    end

    assert_equal "attachment; filename=\"#{registrar.name.parameterize}_white_ips_#{Time.zone.now.to_formatted_s(:number)}.csv\"; " \
      "filename*=UTF-8''#{registrar.name.parameterize}_white_ips_#{Time.zone.now.to_formatted_s(:number)}.csv", response_headers['Content-Disposition']
    assert_equal file_fixture('white_ips.csv').read, page.body
  end
end
