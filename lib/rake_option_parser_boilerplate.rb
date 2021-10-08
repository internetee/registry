module RakeOptionParserBoilerplate
  module_function

  def process_args(options:, banner:, hash: {})
    o = OptionParser.new
    o.banner = banner
    hash.each do |command_line_argument, setup_value|
      o.on(*setup_value) { |result| options[command_line_argument] = result }
    end
    args = o.order!(ARGV) {}
    o.parse!(args)
    options
  end
end
