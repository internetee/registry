Que::Adapters::Base::CAST_PROCS[1184] = lambda do |value|
  case value
  when Time then value
  when String then Time.parse(value)
  else raise "Unexpected time class: #{value.class} (#{value.inspect})"
  end
end
