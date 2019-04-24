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
end