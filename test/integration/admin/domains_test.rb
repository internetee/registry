require 'test_helper'

class AdminDomainsTestTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:admin)
  end

  def test_shows_details
    domain = domains(:shop)
    visit admin_domain_path(domain)
    assert_field nil, with: domain.transfer_code
  end
end
