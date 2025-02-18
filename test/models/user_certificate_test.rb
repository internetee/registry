require 'test_helper'

class UserCertificateTest < ActiveSupport::TestCase
  def setup
    @user = users(:api_bestnames)
    @certificate = user_certificates(:one)
  end

  test "should be valid with required attributes" do
    certificate = UserCertificate.new(
      user: @user,
      private_key: 'dummy_key',
      status: 'pending'
    )
    assert certificate.valid?
  end

  test "should not be valid without user" do
    @certificate.user = nil
    assert_not @certificate.valid?
  end

  test "should not be valid without private_key" do
    @certificate.private_key = nil
    assert_not @certificate.valid?
  end

  test "renewable? should be false without certificate" do
    @certificate.certificate = nil
    assert_not @certificate.renewable?
  end

  test "renewable? should be false when revoked" do
    @certificate.status = 'revoked'
    assert_not @certificate.renewable?
  end

  test "renewable? should be true when expires in less than 30 days" do
    @certificate.expires_at = 29.days.from_now
    assert @certificate.renewable?
  end

  test "expired? should be true when certificate is expired" do
    @certificate.expires_at = 1.day.ago
    assert @certificate.expired?
  end

  test "renew should raise error when certificate is not renewable" do
    @certificate.status = 'revoked'
    assert_raises(RuntimeError) { @certificate.renew }
  end
end
