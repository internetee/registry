require 'test_helper'

class FreeDomainReservationHolderTest < ActiveSupport::TestCase
  def setup
    @holder = FreeDomainReservationHolder.create!(domain_names: ['example1.test', 'example2.test'])
  end

  test "should be valid with valid attributes" do
    holder = FreeDomainReservationHolder.new(
      domain_names: ['example1.test', 'example2.test']
    )
    assert holder.valid?
  end

  test "should generate user_unique_id before create" do
    holder = FreeDomainReservationHolder.create(
      domain_names: ['example.test']
    )
    assert_not_nil holder.user_unique_id
    assert_equal 10, holder.user_unique_id.length
  end


  test "should have many reserved domains" do
    holder = FreeDomainReservationHolder.create(
      domain_names: ['example.test']
    )
    reserved_domain = ReservedDomain.create(
      name: 'example.test',
    )
    assert_includes holder.reserved_domains, reserved_domain
  end
end 