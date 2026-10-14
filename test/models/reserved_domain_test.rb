require 'test_helper'

class ReservedDomainTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @reserved_domain = reserved_domains(:one)
    
    # Mock the domain availability checker
    @original_filter_available = BusinessRegistry::DomainAvailabilityCheckerService.method(:filter_available)
    BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available) do |domains|
      domains # Return all domains as available for testing
    end
  end

  teardown do
    if @original_filter_available
      BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available, @original_filter_available)
    end
  end

  test "fixture is valid" do
    assert @reserved_domain.valid?
  end

  test "aliases registration_code to password" do
    reserved_domain = ReservedDomain.new(password: 'test-123')
    assert_equal 'test-123', reserved_domain.registration_code
  end

  test "should generate password if empty" do
    reserved_domain = ReservedDomain.new(name: 'test.test')
    assert_nil reserved_domain.password
    reserved_domain.save
    assert_not_nil reserved_domain.password
  end

  test "should not override existing password" do
    reserved_domain = ReservedDomain.new(name: 'test.test', password: 'existing-pw')
    reserved_domain.save
    assert_equal 'existing-pw', reserved_domain.password
  end

  test "should generate whois record on save" do
    assert_difference 'Whois::Record.count' do
      ReservedDomain.create(name: 'new-domain.test')
    end
  end

  test "should not generate whois record if domain exists" do
    existing_domain = domains(:shop)
    assert_no_difference 'Whois::Record.count' do
      ReservedDomain.create(name: existing_domain.name)
    end
  end

  test "new_password_for should regenerate password" do
    old_password = @reserved_domain.password
    ReservedDomain.new_password_for(@reserved_domain.name)
    @reserved_domain.reload
    
    assert_not_equal old_password, @reserved_domain.password
  end

  test "reserve_domains_without_payment should handle maximum limit" do
    domain_names = (1..ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST + 1).map { |i| "domain#{i}.test" }
    
    result = ReservedDomain.reserve_domains_without_payment(domain_names)
    
    assert_not result.success
    p result
    assert_includes result.errors, "The maximum number of domain names per request is #{ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST}"
  end

  test "reserve_domains_without_payment should create domains" do
    domain_names = ["new1.test", "new2.test"]
    
    assert_difference 'ReservedDomain.count', 2 do
      result = ReservedDomain.reserve_domains_without_payment(domain_names)
      assert result.success
      assert_equal 2, result.reserved_domains.length
      assert result.reserved_domains.all? { |d| d.password.present? }
    end
  end

  test "reserve_domains_without_payment should filter unavailable domains" do
    # Mock the availability checker to return only one domain
    BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available) do |domains|
      [domains.first]
    end

    domain_names = ["available.test", "unavailable.test"]
    
    assert_difference 'ReservedDomain.count', 1 do
      result = ReservedDomain.reserve_domains_without_payment(domain_names)
      assert result.success
      assert_equal 1, result.reserved_domains.length
      assert_equal "available.test", result.reserved_domains.first.name
    end
  end

  test "expired? should return true when expire_at is in the past" do
    @reserved_domain.expire_at = 1.day.ago
    assert @reserved_domain.expired?
  end

  test "expired? should return false when expire_at is in the future" do
    @reserved_domain.expire_at = 1.day.from_now
    assert_not @reserved_domain.expired?
  end

  test "expired? should return false when expire_at is nil" do
    @reserved_domain.expire_at = nil
    assert_not @reserved_domain.expired?
  end

  test "destroy_if_expired should destroy domain when expired" do
    @reserved_domain.update!(expire_at: 1.day.ago)
    assert_difference 'ReservedDomain.count', -1 do
      @reserved_domain.destroy_if_expired
    end
  end

  test "destroy_if_expired should not destroy domain when not expired" do
    @reserved_domain.update!(expire_at: 1.day.from_now)
    assert_no_difference 'ReservedDomain.count' do
      @reserved_domain.destroy_if_expired
    end
  end

  test "destroy_if_expired should not destroy domain when expire_at is nil" do
    @reserved_domain.expire_at = nil
    assert_no_difference 'ReservedDomain.count' do
      @reserved_domain.destroy_if_expired
    end
  end

  test "reserve_domains_without_payment should create holder and return unique_id" do
    domain_names = ['test1.test', 'test2.test']
    
    result = ReservedDomain.reserve_domains_without_payment(domain_names)
    
    assert result.success
    assert_not_nil result.user_unique_id
    assert_equal 10, result.user_unique_id.length
    assert_equal domain_names.count, result.reserved_domains.count
  end

  test "reserve_domains_without_payment should return error when no domains available" do
    domain_names = ['test1.test']

    BusinessRegistry::DomainAvailabilityCheckerService.stub :filter_available, [] do
      result = ReservedDomain.reserve_domains_without_payment(domain_names)

      assert_not result.success
      assert_nil result.user_unique_id
      assert_equal "No available domains", result.errors
    end
  end

  test "release_expired should remove expired reservations and return released count" do
    expired_one = ReservedDomain.create!(name: 'expired-one.test', expire_at: 1.day.ago)
    expired_two = ReservedDomain.create!(name: 'expired-two.test', expire_at: 1.hour.ago)
    future_domain = ReservedDomain.create!(name: 'future.test', expire_at: 1.day.from_now)

    released = nil
    assert_difference 'ReservedDomain.count', -2 do
      released = ReservedDomain.release_expired
    end

    assert_equal 2, released
    assert_not ReservedDomain.exists?(expired_one.id)
    assert_not ReservedDomain.exists?(expired_two.id)
    assert ReservedDomain.exists?(future_domain.id)
    assert ReservedDomain.exists?(@reserved_domain.id)
  end

  test "release_expired should keep reservation expiring exactly at the boundary" do
    at = Time.current
    boundary_domain = ReservedDomain.create!(name: 'boundary.test', expire_at: at)

    assert_no_difference 'ReservedDomain.count' do
      assert_equal 0, ReservedDomain.release_expired(at: at)
    end
    assert ReservedDomain.exists?(boundary_domain.id)
  end

  test "release_expired should record release reason in version history" do
    frozen_time = Time.zone.parse('2026-10-02 00:35:00')
    domain = ReservedDomain.create!(name: 'audited.test', expire_at: frozen_time - 1.day)

    travel_to frozen_time do
      ReservedDomain.release_expired
    end

    versions = Version::ReservedDomainVersion.where(item_id: domain.id).order(:id).last(2)
    assert_equal %w[update destroy], versions.map(&:event)

    destroy_version = versions.last
    assert_includes destroy_version.object['updator_str'], 'Automated daily cleanup job'
    assert_includes destroy_version.object['updator_str'], 'Expired reservation deadline reached'
    assert_includes destroy_version.object['updator_str'], frozen_time.iso8601
    assert_includes destroy_version.whodunnit, 'Automated daily cleanup job'
    assert_includes destroy_version.whodunnit, 'Expired reservation deadline reached'
    assert_includes destroy_version.whodunnit, frozen_time.iso8601
  end

  test "release_if_expired should return false when reservation was extended after loading" do
    domain = ReservedDomain.create!(name: 'extended.test', expire_at: 1.day.ago)
    ReservedDomain.where(id: domain.id).update_all(expire_at: 1.day.from_now)

    assert_not domain.release_if_expired(process: 'Concurrent extension')
    assert ReservedDomain.exists?(domain.id)
  end

  test "release_expired should continue after a failing record" do
    failing_domain = ReservedDomain.create!(name: 'failing.test', expire_at: 1.day.ago)
    expired_domain = ReservedDomain.create!(name: 'expired.test', expire_at: 1.day.ago)
    # update_all bypasses validations, so the audit update! fails on the invalid name
    ReservedDomain.where(id: failing_domain.id).update_all(name: 'not a domain name')

    assert_equal 1, ReservedDomain.release_expired
    assert ReservedDomain.exists?(failing_domain.id)
    assert_not ReservedDomain.exists?(expired_domain.id)
  end

  test "release_expired should enqueue whois record update for released domains" do
    ReservedDomain.create!(name: 'whois-release.test', expire_at: 1.day.ago)

    assert_enqueued_with(job: UpdateWhoisRecordJob, args: ['whois-release.test', 'reserved']) do
      ReservedDomain.release_expired
    end
  end

  test "destroy_if_expired should mark release as business registry availability check" do
    domain = ReservedDomain.create!(name: 'availability-check.test', expire_at: 1.day.ago)

    domain.destroy_if_expired

    version = Version::ReservedDomainVersion.where(item_id: domain.id).order(:id).last
    assert_equal 'destroy', version.event
    assert_includes version.whodunnit, 'Business registry availability check'
  end

  test "release_expired records expiry_job audit on versions" do
    domain = ReservedDomain.create!(name: 'expiry-audit.test', expire_at: 1.day.ago)

    ReservedDomain.release_expired

    version = Version::ReservedDomainVersion.where(item_id: domain.id).order(:id).last
    assert_equal 'destroy', version.event
    assert_equal 'expiry_job', version.source
    assert_equal 'reservation_expired', version.reason
    assert_equal 'expiry-audit.test', version.domain_name
  end

  test "destroy_if_expired records availability_check audit on versions" do
    domain = ReservedDomain.create!(name: 'lazy-audit.test', expire_at: 1.day.ago)

    domain.destroy_if_expired

    version = Version::ReservedDomainVersion.where(item_id: domain.id).order(:id).last
    assert_equal 'destroy', version.event
    assert_equal 'availability_check', version.source
    assert_equal 'reservation_expired', version.reason
    assert_equal 'lazy-audit.test', version.domain_name
  end

  test "lazy expiry inside business registry context keeps availability_check source" do
    domain = ReservedDomain.create!(name: 'nested-expiry.test', expire_at: 1.day.ago)

    PaperTrail.request(whodunnit: 'Business Registry API') do
      ReservedDomain::Audit.set(source: 'business_registry', reason: nil,
                              reason_note: nil, registrar_id: nil) do
        domain.destroy_if_expired
      end
    end

    version = Version::ReservedDomainVersion.where(item_id: domain.id).order(:id).last
    assert_equal 'destroy', version.event
    assert_equal 'availability_check', version.source
    assert_equal 'reservation_expired', version.reason
    assert_includes version.whodunnit, 'Business registry availability check'
    assert_includes version.whodunnit, 'Expired reservation deadline reached'
  end

  test "release_expired should return zero when no reservations are expired" do
    assert_no_difference 'ReservedDomain.count' do
      assert_equal 0, ReservedDomain.release_expired
    end
  end

  test "expire_at_for returns 23:59:59 of the last full day" do
    from = Time.zone.parse('2026-10-01 13:43:00')

    assert_equal Time.zone.parse('2026-10-08 23:59:59'),
                 ReservedDomain.expire_at_for(ReservedDomain::FREE_RESERVATION_EXPIRY, from: from)
  end

  test "expire_at_for keeps full calendar days across DST change" do
    from = Time.zone.parse('2026-10-23 13:43:00')

    assert_equal Time.zone.parse('2026-10-30 23:59:59'),
                 ReservedDomain.expire_at_for(ReservedDomain::FREE_RESERVATION_EXPIRY, from: from)
  end

  test "expire_at_for keeps full calendar days across leap day" do
    from = Time.zone.parse('2028-02-29 13:43:00')

    assert_equal Time.zone.parse('2029-02-28 23:59:59'),
                 ReservedDomain.expire_at_for(ReservedDomain::PAID_RESERVATION_EXPIRY, from: from)
  end

  test "expire_at_for keeps full calendar days across year boundary" do
    from = Time.zone.parse('2026-12-28 10:00:00')

    assert_equal Time.zone.parse('2027-01-04 23:59:59'),
                 ReservedDomain.expire_at_for(ReservedDomain::FREE_RESERVATION_EXPIRY, from: from)
  end

  test "reserve_domains_without_payment sets expire_at to the end of the last full day" do
    travel_to Time.zone.parse('2026-10-01 13:43:00') do
      result = ReservedDomain.reserve_domains_without_payment(['new-reserved.test'])

      assert result.success
      assert_equal Time.zone.parse('2026-10-08 23:59:59'), result.reserved_domains.first.expire_at
    end
  end
end
