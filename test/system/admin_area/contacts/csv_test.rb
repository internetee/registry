require 'application_system_test_case'

class ContactsCsvTest < ApplicationSystemTestCase
  setup { sign_in users(:admin) }

  def test_download_contacts_list_as_csv
    travel_to Time.zone.parse('2010-07-05 10:30')
    Contact.all.each do |contact|
      contact.created_at = Time.zone.now
      contact.save(:validate => false)
    end

    visit admin_contacts_url
    click_link('CSV')

    assert_equal "attachment; filename=\"contacts_#{Time.zone.now.to_formatted_s(:number)}.csv\"; filename*=UTF-8''contacts_#{Time.zone.now.to_formatted_s(:number)}.csv", response_headers['Content-Disposition']
    assert_equal file_fixture('contacts.csv').read, page.body
  end
end
