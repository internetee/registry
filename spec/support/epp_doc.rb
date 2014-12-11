class EppDoc
  RSpec::Core::Formatters.register self, :start, :example_started, :example_passed, :example_pending

  def initialize(output)
    @output = output
  end

  def start(example_count)
    @output.puts '# EPP REQUEST - RESPONSE DOCUMENTATION'
    @output.puts "GENERATED AT: #{Time.now}  "
    @output.puts "EXAMPLE COUNT: #{example_count.count}  "
    @output.puts "\n---\n\n"
  end

  def example_started(notification)
    @output.puts "### #{notification.example.full_description}  \n\n"
  end

  def example_passed(_example)
    # dash = '-' * 48
    # @output.puts "#{dash}PASS#{dash}\n\n"
  end

  def example_failed(_example)
    # dash = '-' * 48
    # @output.puts "#{dash}FAIL#{dash}\n\n"
  end

  def example_pending(_example)
    # dash_1 = '-' * 47
    # dash_2 = '-' * 46
    # @output.puts "#{dash_1}PENDING#{dash_2}\n\n"
  end
end
