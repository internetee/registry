require 'test_helper'

class ApplicationMailerTest < ActiveSupport::TestCase
  def test_reads_default_from_setting_from_config
    assert_equal 'no-reply@registry.test', ENV['action_mailer_default_from']

    mailer = Class.new(ApplicationMailer) do
      def test
        # Empty block to avoid template rendering
        mail {}
      end
    end
    email = mailer.test

    assert_equal ['no-reply@registry.test'], email.from
  end

  def test_encodes_address_fields_as_punycode
    mailer = Class.new(ApplicationMailer) do
      def test
        # Empty block to avoid template rendering
        mail(from: 'from@münchen.test', to: 'to@münchen.test', cc: 'cc@münchen.test',
             bcc: 'bcc@münchen.test') {}
      end
    end

    email = mailer.test
    email.deliver_now

    assert_equal ['from@xn--mnchen-3ya.test'], email.from
    assert_equal ['to@xn--mnchen-3ya.test'], email.to
    assert_equal ['cc@xn--mnchen-3ya.test'], email.cc
    assert_equal ['bcc@xn--mnchen-3ya.test'], email.bcc
  end
end