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
    assert_equal "Set on #{domains(:shop).name}: #{DomainStatus::PENDING_UPDATE}. Removed from #{domains(:shop).name}: #{DomainStatus::OK}", domains(:shop).registrar.notifications.last.text
    
    patch admin_domain_path(domains(:shop)), params: { domain: { statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION] } }
    assert_equal "Set on #{domains(:shop).name}: #{DomainStatus::PENDING_DELETE_CONFIRMATION}. Removed from #{domains(:shop).name}: #{DomainStatus::PENDING_UPDATE}", domains(:shop).registrar.notifications.last.text
  end
end
