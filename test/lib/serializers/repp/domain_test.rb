require 'test_helper'
require 'serializers/repp/domain'

class SerializersReppDomainTest < ActiveSupport::TestCase
  def setup
    @domain = domains(:airport)
  end

  def test_returns_status_notes
    status_notes = { 'serverForceDelete' => '`@internet2.ee' }
    @domain.update!(statuses: %w[serverForceDelete], status_notes: status_notes)
    @serializer = Serializers::Repp::Domain.new(@domain)
    @json = @serializer.to_json

    assert_equal(status_notes, @json[:statuses])
  end
end
