require 'test_helper'

class AdminAreaDomainDetailsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @domain = domains(:shop)
  end

  def test_discarded_domain_has_corresponding_label
    travel_to Time.zone.parse('2010-07-05 10:30')
    @domain.delete_at = Time.zone.parse('2010-07-05 10:00')

    visit admin_domain_url(@domain)
    assert_no_css 'span.label.label-warning', text: 'deleteCandidate'

    @domain.discard

    visit admin_domain_url(@domain)
    assert_css 'span.label.label-warning', text: 'deleteCandidate'
  end
end
