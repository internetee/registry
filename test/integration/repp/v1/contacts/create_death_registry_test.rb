require 'test_helper'

class ReppV1ContactsCreateDeathRegistryTest < ActionDispatch::IntegrationTest
  DECEASED_IDENT = '39708290069'.freeze

  setup do
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    @auth_headers = { 'Authorization' => "Basic #{token}" }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!

    @dir = Dir.mktmpdir
    @death_file = File.join(@dir, 'deaths.txt')
    File.write(@death_file, "#{DECEASED_IDENT};2026-01-01\n")
    ENV['death_registry_file_path'] = @death_file
    ENV['validate_deceased_contacts'] = 'true'
  end

  teardown do
    ENV.delete('death_registry_file_path')
    ENV.delete('validate_deceased_contacts')
    FileUtils.rm_rf(@dir)
  end

  def test_rejects_estonian_private_person_found_in_death_registry
    assert_no_difference 'Contact.count' do
      post '/repp/v1/contacts', headers: @auth_headers, params: request_body(ident: DECEASED_IDENT)
    end
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2003, json[:code]
    assert_includes json[:message], 'Ident is invalid'
  end

  def test_creates_contact_and_saves_check_time_when_person_is_not_in_death_registry
    File.write(@death_file, "38001010000;2026-01-01\n")

    travel_to Time.zone.parse('2026-10-19 10:00') do
      post '/repp/v1/contacts', headers: @auth_headers, params: request_body(ident: DECEASED_IDENT)
    end
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    contact = Contact.find_by(code: json[:data][:contact][:code])
    assert_equal Time.zone.parse('2026-10-19 10:00'), contact.death_registry_checked_at
    assert_nil contact.death_date
  end

  def test_creates_contact_without_check_time_when_death_registry_file_is_missing
    File.delete(@death_file)

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body(ident: DECEASED_IDENT)
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_nil Contact.find_by(code: json[:data][:contact][:code]).death_registry_checked_at
  end

  def test_creates_contact_without_check_time_when_death_registry_file_is_stale
    File.utime(9.days.ago.to_time, 9.days.ago.to_time, @death_file)

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body(ident: DECEASED_IDENT)
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_nil Contact.find_by(code: json[:data][:contact][:code]).death_registry_checked_at
  end

  def test_does_not_check_foreign_private_person
    post '/repp/v1/contacts', headers: @auth_headers,
                              params: request_body(ident: DECEASED_IDENT, country_code: 'LV')
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_nil Contact.find_by(code: json[:data][:contact][:code]).death_registry_checked_at
  end

  def test_does_not_check_when_validation_is_disabled
    ENV['validate_deceased_contacts'] = 'false'

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body(ident: DECEASED_IDENT)
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_nil Contact.find_by(code: json[:data][:contact][:code]).death_registry_checked_at
  end

  private

  def request_body(ident:, country_code: 'EE')
    {
      contact: {
        name: 'John Doe',
        phone: '+372.51111112',
        email: 'john@inbox.test',
        ident: { ident_type: 'priv', ident_country_code: country_code, ident: ident },
      },
    }
  end
end
