require "test_helper"

class DomainDeleteJobTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.parse('2010-07-05')
    @domain = domains(:shop)
    @domain.update!(delete_date:'2010-07-05')
    @domain.reload
  end

  def test_delete_domain
    dom = Domain.find_by(id: @domain.id)
    assert dom

    DomainDeleteJob.perform_now(@domain.id)

    dom = Domain.find_by(id: @domain.id)
    assert_nil dom
  end
end
