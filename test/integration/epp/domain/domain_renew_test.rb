require 'test_helper'

class EppDomainRenewTest < EppTestCase
  self.use_transactional_fixtures = false

  setup do
    @domain = domains(:shop)
    travel_to Time.zone.parse('2010-07-05')
  end

  def test_renews_domain
    travel_to Time.zone.parse('2010-07-05')
    original_valid_to = @domain.valid_to
    default_renewal_period = 1.year
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{@domain.name}</domain:name>
              <domain:curExpDate>#{@domain.expire_time.to_date}</domain:curExpDate>
              <domain:period unit="y">1</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML

    post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    @domain.reload

    assert_epp_response :completed_successfully
    assert_equal original_valid_to + default_renewal_period, @domain.valid_to
  end

  def test_domain_cannot_be_renewed_when_invalid
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>invalid.test</domain:name>
              <domain:curExpDate>2010-07-05</domain:curExpDate>
              <domain:period unit="m">1</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML

    assert_no_changes -> { domains(:invalid).valid_to } do
      post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    assert_epp_response :object_status_prohibits_operation
  end

  def test_domain_cannot_be_renewed_when_belongs_to_another_registrar
    session = epp_sessions(:api_bestnames)
    domain = domains(:metro)
    assert_not_equal session.user.registrar, domain.registrar

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{domain.name}</domain:name>
              <domain:curExpDate>#{domain.valid_to.to_date}</domain:curExpDate>
              <domain:period unit="m">1</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML

    assert_no_changes -> { domains(:invalid).valid_to } do
      post '/epp/command/renew', { frame: request_xml },
           'HTTP_COOKIE' => "session=#{session.session_id}"
    end
    assert_epp_response :authorization_error
  end

  def test_insufficient_funds
    session = epp_sessions(:api_bestnames)
    session.user.registrar.accounts.first.update!(balance: 0)
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{@domain.name}</domain:name>
              <domain:curExpDate>#{@domain.expire_time.to_date}</domain:curExpDate>
              <domain:period unit="y">1</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML

    @domain.reload
    assert_no_difference -> { @domain.valid_to } do
      post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session.session_id}"
    end
    assert_epp_response :billing_failure
  end

  def test_no_price
    assert_nil Billing::Price.find_by(duration: '2 months')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{@domain.name}</domain:name>
              <domain:curExpDate>#{@domain.expire_time.to_date}</domain:curExpDate>
              <domain:period unit="m">2</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML

    assert_no_changes -> { @domain.valid_to } do
      post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    assert_epp_response :billing_failure
  end

  def test_fails_when_provided_expiration_date_is_wrong
    provided_expiration_date = Date.parse('2010-07-06')
    assert_not_equal provided_expiration_date, @domain.valid_to

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{@domain.name}</domain:name>
              <domain:curExpDate>#{provided_expiration_date}</domain:curExpDate>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML

    assert_no_changes -> { @domain.valid_to } do
      post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    assert_epp_response :parameter_value_policy_error
  end
end
