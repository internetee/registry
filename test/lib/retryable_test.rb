# frozen_string_literal: true

require 'test_helper'

class RetryableTest < ActiveSupport::TestCase
  class TestClass
    include Retryable

    attr_reader :call_count

    def initialize
      @call_count = 0
    end

    def test_retriable_method(should_fail: false, fail_count: 2)
      with_retry(
        max_attempts: 3,
        retry_delay: 0.1,
        logger: Rails.logger
      ) do
        @call_count += 1
        
        if should_fail && @call_count <= fail_count
          raise StandardError, "Тестовая ошибка #{@call_count}"
        end
        
        'success'
      end
    end

    def test_retriable_with_fallback(should_fail: true)
      with_retry(
        max_attempts: 2,
        retry_delay: 0.1,
        logger: Rails.logger,
        fallback: -> { 'fallback' }
      ) do
        @call_count += 1
        raise StandardError, 'Постоянная ошибка' if should_fail
        'success'
      end
    end
  end

  test 'should retry specified number of times and succeed' do
    test_object = TestClass.new
    result = test_object.test_retriable_method(should_fail: true, fail_count: 2)
    
    assert_equal 3, test_object.call_count
    assert_equal 'success', result
  end

  test 'should succeed on first try if no errors' do
    test_object = TestClass.new
    result = test_object.test_retriable_method(should_fail: false)
    
    assert_equal 1, test_object.call_count
    assert_equal 'success', result
  end

  test 'should use fallback when all retries fail' do
    test_object = TestClass.new
    result = test_object.test_retriable_with_fallback(should_fail: true)
    
    assert_equal 2, test_object.call_count
    assert_equal 'fallback', result
  end
end 