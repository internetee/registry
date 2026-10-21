require 'test_helper'

class FeatureTest < ActiveSupport::TestCase
  def test_auto_renew_is_enabled_only_by_the_exact_true_string
    original = ENV['auto_renew_enabled']

    ['true', 'false', nil, '', 'TRUE', '1'].each do |value|
      ENV['auto_renew_enabled'] = value
      assert_equal value == 'true', Feature.auto_renew_enabled?
    end
  ensure
    ENV['auto_renew_enabled'] = original
  end
end
