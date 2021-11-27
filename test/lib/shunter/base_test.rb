# frozen_string_literal: true

require "test_helper"
require "action_controller"
require "pry"

class BaseTest < Minitest::Test
  ENV["shunter_enabled"] = 'true'

  def test_throttling_works_on_inclusion
    ENV["shunter_default_adapter"] = "Shunter::Adapters::Memory"
    ENV["shunter_default_threshold"] = "100"
    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter.clear!

    TestKlass.new.throttle do
      TestKlass.new.test
    end
  end

  class TestKlass < ::ActionController::Base
    THROTTLED_ACTIONS = %i[test].freeze
    include Shunter::Integration::Throttle

    def test
      "test"
    end

    def throttled_user
      @throttled_user ||= OpenStruct.new(id: 1)
    end
  end
end
