require 'test_helper'

class DomainsControllerTest < ApplicationIntegrationTest

  def setup
    @domain = domains(:shop)
    @admin = users(:admin)
    sign_in @admin
  end

  def test_inform_registrar_about_status_changes
    patch admin_domain_path(domains(:shop)), params: { domain: { statuses: [DomainStatus::PENDING_UPDATE,] } }

    # Status OK is removed because, if:
    # (statuses.length > 1) || !valid?
    # then status OK is removed by manage_automatic_statuses method in domain.rb
    notifications = domains(:shop).registrar.notifications.last(2)
    assert_equal "#{DomainStatus::PENDING_UPDATE} set on domain #{domains(:shop).name}", notifications.first.text
    assert_equal "#{DomainStatus::OK} is cancelled on domain #{domains(:shop).name}", notifications.last.text
    
    patch admin_domain_path(domains(:shop)), params: { domain: { statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION] } }
    notifications = domains(:shop).registrar.notifications.last(2)
    assert_equal "#{DomainStatus::PENDING_DELETE_CONFIRMATION} set on domain #{domains(:shop).name}", notifications.first.text
    assert_equal "#{DomainStatus::PENDING_UPDATE} is cancelled on domain #{domains(:shop).name}", notifications.last.text
  end
end
