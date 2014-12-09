class EppDoc
  RSpec::Core::Formatters.register self, :example_started, :example_passed, :example_failed

  def initialize(output)
    @output = output
  end

  def example_started(notification)
    desc = notification.example.full_description
    @output.puts '-' * desc.length
    @output.puts desc
    @output.puts '-' * desc.length
  end

  def example_passed(_example)
    @output << "\n\n"
  end

  def example_failed(_example)
    @output << "\n\n"
  end
end
