require 'test_helper'

class AdminAreaDomainDetailsTest < ActionDispatch::IntegrationTest
  setup do
    login_as users(:admin)
    @domain = domains(:shop)
  end

  def test_discarded_domain_has_corresponding_label
    visit admin_domain_url(@domain)
    assert_no_css 'span.label.label-warning', text: 'deleteCandidate'
    @domain.discard
    visit admin_domain_url(@domain)
    assert_css 'span.label.label-warning', text: 'deleteCandidate'
  end
end
