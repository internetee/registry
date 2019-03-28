require 'test_helper'

class AdminAreaDomainDetailsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    @domain = domains(:shop)
  end

  def test_discarded_domain_has_corresponding_label
    @domain.delete_date = '2010-07-04'
    travel_to Time.zone.parse('2010-07-05')

    visit admin_domain_url(@domain)
    assert_no_css 'span.label.label-warning', text: 'deleteCandidate'

    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    visit admin_domain_url(@domain)
    assert_css 'span.label.label-warning', text: 'deleteCandidate'
  end
end
