require 'test_helper'

class ReppV1DomainsBulkRenewTest < ActionDispatch::IntegrationTest
  def setup
    travel_to Time.zone.parse('2010-07-05 10:30')
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_renews_domains
    payload = {
      "domains": [
        'shop.test',
        'airport.test',
        'library.test'
      ],
      "renew_period": "1y"
    }

    assert_changes -> { Domain.find_by(name: 'shop.test').valid_to } do
      assert_changes -> { Domain.find_by(name: 'airport.test').valid_to } do
        assert_changes -> { Domain.find_by(name: 'library.test').valid_to } do
          post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
          json = JSON.parse(response.body, symbolize_names: true)

          assert_response :ok
          assert_equal 1000, json[:code]
          assert_equal 'Command completed successfully', json[:message]
          assert json[:data][:updated_domains].include? 'shop.test'
          assert json[:data][:updated_domains].include? 'airport.test'
          assert json[:data][:updated_domains].include? 'library.test'
        end
      end
    end
  end

  def test_keeps_update_prohibited_status
    domain = domains(:shop)
    domain.update(statuses: [DomainStatus::CLIENT_UPDATE_PROHIBITED, DomainStatus::SERVER_UPDATE_PROHIBITED])
    payload = {
      "domains": [
        'shop.test'
      ],
      "renew_period": "1y"
    }

    assert_changes -> { Domain.find_by(name: 'shop.test').valid_to } do
      post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :ok
      assert_equal 1000, json[:code]
      assert_equal 'Command completed successfully', json[:message]
      assert json[:data][:updated_domains].include? 'shop.test'
    end
    domain.reload
    assert_equal domain.statuses, [DomainStatus::CLIENT_UPDATE_PROHIBITED, DomainStatus::SERVER_UPDATE_PROHIBITED]
  end

  def test_multi_domains_сannot_be_renewed_with_renew_prohibited_status
    array_domains = [domains(:shop), domains(:airport)]
    payload = {
      "domains": array_domains.pluck(:name),
      "renew_period": "1y"
    }

    array_domains.each do |domain|
      set_status_for_domain(domain, [DomainStatus::CLIENT_RENEW_PROHIBITED, DomainStatus::SERVER_RENEW_PROHIBITED])
    end

    assert_renew_prohibited_domains(array_domains, payload)
  end

  def test_throws_error_when_domain_not_renewable
    payload = {
      "domains": [
        'invalid.test',
      ],
      "renew_period": "1y"
    }
    assert_no_changes -> { Domain.find_by(name: 'invalid.test').valid_to } do
      post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :bad_request
      assert_equal 2002, json[:code]
      assert_equal 'Domain renew error for invalid.test', json[:message]
    end
  end

  def test_throws_error_when_not_enough_balance
    price = Billing::Price.last
    price.price_cents = 99999999
    price.save(validate: false)

    payload = {
      "domains": [
        'invalid.test',
      ],
      "renew_period": "1y"
    }

    assert_no_changes -> { Domain.find_by(name: 'invalid.test').valid_to } do
      post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :bad_request
      assert_equal 2002, json[:code]
      assert_equal 'Billing failure - credit balance low', json[:message]
    end
  end

  def test_throws_error_if_invalid_renew_period
    payload = {
      "domains": [
        'shop.test'
      ],
      "renew_period": "nope"
    }

    post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2005, json[:code]
    assert_equal 'Invalid renew period', json[:message]
  end

  private

  def set_status_for_domain(domain, statuses)
    domain.update(statuses: statuses)

    if statuses.size > 1
      statuses.each do |status|
        assert domain.statuses.include? status
      end
    else
      assert domain.statuses.include? statuses
    end
  end

  def bulk_renew(payload)
    post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
    JSON.parse(response.body, symbolize_names: true)
  end

  def assert_renew_prohibited_domains(domains, payload)
    assert_no_changes -> { Domain.where(name: domains).pluck(:valid_to) } do
      json = bulk_renew(payload)

      assert_response :bad_request
      assert_equal 2002, json[:code]
      assert domains.all? do |domain|
        json[:message].include? "Domain renew error for #{domain.name}"
      end
      assert json[:data].empty?
    end
  end
end
