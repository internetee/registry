class EppDoc
  RSpec::Core::Formatters.register self, :start, :example_started

  def initialize(output)
    @output = output
  end

  def start(example_count)
    @output.puts '# EPP REQUEST - RESPONSE EXAMPLES'
    @output.puts "GENERATED AT: #{Time.zone.now}  "
    @output.puts "EXAMPLE COUNT: #{example_count.count}  "
    @output.puts "\n---\n\n"
  end

  def example_started(notification)
    @output.puts "### #{notification.example.full_description}  \n\n"
  end
end
