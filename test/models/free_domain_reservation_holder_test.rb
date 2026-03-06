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

  test "output_reserved_domains should return correct structure with status reserved" do
    domain_names = ['test1.test', 'test2.test']
    holder = FreeDomainReservationHolder.create!(domain_names: domain_names)

    domain_names.each do |name|
      ReservedDomain.create!(
        name: name,
        password: 'test-password',
        expire_at: Time.current + 7.days
      )
    end

    output = holder.output_reserved_domains

    assert_equal domain_names.length, output.length
    output.each do |domain|
      assert_includes domain_names, domain[:name]
      assert_not_nil domain[:password]
      assert_not_nil domain[:expire_at]
      assert_equal 'reserved', domain[:status]
    end
  end

  test "output_reserved_domains should return status registered when domain is registered" do
    domain_names = ['shop.test']
    holder = FreeDomainReservationHolder.create!(domain_names: domain_names)

    ReservedDomain.create!(name: 'shop.test', password: 'test-password', expire_at: Time.current + 7.days)
    # Domain exists in domains table — means it's been registered via registrar
    Domain.find_or_create_by!(name: 'shop.test') do |d|
      d.registrar = registrars(:bestnames)
      d.registrant = contacts(:john)
      d.period = 1
      d.period_unit = 'y'
      d.reserved_pw = 'test-password'
    end

    output = holder.output_reserved_domains

    assert_equal 1, output.length
    assert_equal 'registered', output.first[:status]
    assert_nil output.first[:password]
    assert_nil output.first[:expire_at]
  end

  test "output_reserved_domains should return status expired when reservation no longer exists" do
    domain_names = ['gone.test']
    holder = FreeDomainReservationHolder.create!(domain_names: domain_names)
    # No ReservedDomain record and no Domain record

    output = holder.output_reserved_domains

    assert_equal 1, output.length
    assert_equal 'expired', output.first[:status]
  end
end 