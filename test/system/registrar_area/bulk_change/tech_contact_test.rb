require 'application_system_test_case'

class RegistrarAreaTechContactBulkChangeTest < ApplicationSystemTestCase
  setup do
    sign_in users(:api_bestnames)
  end

  def test_replace_domain_contacts_of_current_registrar
    request_stub = stub_request(:patch, /domains\/contacts/)
                     .with(body: { current_contact_id: 'william-001', new_contact_id: 'john-001' },
                           basic_auth: ['test_bestnames', 'testtest'])
                     .to_return(body: { affected_domains: %w[foo.test bar.test],
                                        skipped_domains: %w[baz.test qux.test] }.to_json,
                                status: 200)

    visit registrar_domains_url
    click_link 'Bulk change'

    fill_in 'Current contact ID', with: 'william-001'
    fill_in 'New contact ID', with: 'john-001'
    click_on 'Replace technical contacts'

    assert_requested request_stub
    assert_current_path registrar_domains_path
    assert_text 'Technical contacts have been successfully replaced'
    assert_text 'Affected domains: foo.test, bar.test'
    assert_text 'Skipped domains: baz.test, qux.test'
  end

  def test_fails_gracefully
    stub_request(:patch, /domains\/contacts/)
      .to_return(status: 400,
                 body: { error: { message: 'epic fail' } }.to_json,
                 headers: { 'Content-type' => 'application/json' })

    visit registrar_domains_url
    click_link 'Bulk change'

    fill_in 'Current contact ID', with: 'william-001'
    fill_in 'New contact ID', with: 'john-001'
    click_on 'Replace technical contacts'

    assert_text 'epic fail'
    assert_field 'Current contact ID', with: 'william-001'
    assert_field 'New contact ID', with: 'john-001'
  end
end
