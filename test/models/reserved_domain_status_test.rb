require 'test_helper'

class ReservedDomainStatusTest < ActiveSupport::TestCase
  def setup
    @reserved_domain_status = ReservedDomainStatus.new(name: 'example.test')
  end

  test "should be valid with valid attributes" do
    assert @reserved_domain_status.valid?
  end

  test "should generate access_token on create" do
    @reserved_domain_status.save
    assert_not_nil @reserved_domain_status.access_token
  end

  test "should set token_created_at on create" do
    @reserved_domain_status.save
    assert_not_nil @reserved_domain_status.token_created_at
    assert_in_delta Time.current, @reserved_domain_status.token_created_at, 1.second
  end

  test "token should not be expired when newly created" do
    @reserved_domain_status.save
    assert_not @reserved_domain_status.token_expired?
  end

  test "token should be expired after 30 days" do
    @reserved_domain_status.save
    @reserved_domain_status.update_column(:token_created_at, 31.days.ago)
    assert @reserved_domain_status.token_expired?
  end

  test "refresh_token should update token and token_created_at" do
    @reserved_domain_status.save
    old_token = @reserved_domain_status.access_token
    old_created_at = @reserved_domain_status.token_created_at

    @reserved_domain_status.refresh_token

    assert_not_equal old_token, @reserved_domain_status.access_token
    assert_not_equal old_created_at, @reserved_domain_status.token_created_at
    assert_in_delta Time.current, @reserved_domain_status.token_created_at, 1.second
  end

  test "should have correct enum values for status" do
    assert_equal 0, ReservedDomainStatus.statuses[:pending]
    assert_equal 1, ReservedDomainStatus.statuses[:paid]
    assert_equal 2, ReservedDomainStatus.statuses[:canceled]
    assert_equal 3, ReservedDomainStatus.statuses[:failed]
  end
end