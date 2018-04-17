module ActiveSupport
  module Testing
    module Assertions
      UNTRACKED = Object.new # :nodoc:

      # Assertion that the result of evaluating an expression is changed before
      # and after invoking the passed in block.
      #
      #   assert_changes 'Status.all_good?' do
      #     post :create, params: { status: { ok: false } }
      #   end
      #
      # You can pass the block as a string to be evaluated in the context of
      # the block. A lambda can be passed for the block as well.
      #
      #   assert_changes -> { Status.all_good? } do
      #     post :create, params: { status: { ok: false } }
      #   end
      #
      # The assertion is useful to test side effects. The passed block can be
      # anything that can be converted to string with #to_s.
      #
      #   assert_changes :@object do
      #     @object = 42
      #   end
      #
      # The keyword arguments :from and :to can be given to specify the
      # expected initial value and the expected value after the block was
      # executed.
      #
      #   assert_changes :@object, from: nil, to: :foo do
      #     @object = :foo
      #   end
      #
      # An error message can be specified.
      #
      #   assert_changes -> { Status.all_good? }, 'Expected the status to be bad' do
      #     post :create, params: { status: { incident: true } }
      #   end
      def assert_changes(expression, message = nil, from: UNTRACKED, to: UNTRACKED, &block)
        exp = expression.respond_to?(:call) ? expression : -> { eval(expression.to_s, block.binding) }

        before = exp.call
        retval = yield

        unless from == UNTRACKED
          error = "#{expression.inspect} isn't #{from.inspect}"
          error = "#{message}.\n#{error}" if message
          assert from === before, error
        end

        after = exp.call

        if to == UNTRACKED
          error = "#{expression.inspect} didn't changed"
          error = "#{message}.\n#{error}" if message
          assert_not_equal before, after, error
        else
          error = "#{expression.inspect} didn't change to #{to}"
          error = "#{message}.\n#{error}" if message
          assert to === after, error
        end

        retval
      end

      # Assertion that the result of evaluating an expression is changed before
      # and after invoking the passed in block.
      #
      #   assert_no_changes 'Status.all_good?' do
      #     post :create, params: { status: { ok: true } }
      #   end
      #
      # An error message can be specified.
      #
      #   assert_no_changes -> { Status.all_good? }, 'Expected the status to be good' do
      #     post :create, params: { status: { ok: false } }
      #   end
      def assert_no_changes(expression, message = nil, &block)
        exp = expression.respond_to?(:call) ? expression : -> { eval(expression.to_s, block.binding) }

        before = exp.call
        retval = yield
        after = exp.call

        error = "#{expression.inspect} did change to #{after}"
        error = "#{message}.\n#{error}" if message
        assert_equal before, after, error

        retval
      end
    end
  end
end
