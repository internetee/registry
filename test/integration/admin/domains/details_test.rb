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

  def test_keep_a_domain
    @domain.discard
    visit edit_admin_domain_url(@domain)
    click_link_or_button 'Remove deleteCandidate status'
    @domain.reload
    refute @domain.discarded?
    assert_text 'deleteCandidate status has been removed'
    assert_no_link 'Remove deleteCandidate status'
  end
end
