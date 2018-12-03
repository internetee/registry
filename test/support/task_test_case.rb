class TaskTestCase < ActiveSupport::TestCase
  setup do
    # Rake tasks usually display some results, which mixes up with test results.
    # This suppresses default stdout and makes Rails.env.test? checks unnecessary.
    @original_stdout = $stdout
    $stdout = File.open(File::NULL, 'w')
    ActiveSupport::Deprecation.warn('`TaskTestCase` class will be removed soon.' \
                                    ' Use `capture_io` and `assert_output` instead')
  end

  teardown do
    $stdout = @original_stdout
  end
end
