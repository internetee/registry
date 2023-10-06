# frozen_string_literal: true

require_relative "../../config/environment"
require 'benchmark/ips' # Подразумевается, что gem 'benchmark-ips' установлен

date_to = Date.strptime("10.23", '%m.%y').end_of_month
date_from = Date.strptime("01.22", '%m.%y').end_of_month
controller = Repp::V1::StatsController.new

time_before = Benchmark.realtime do
  ActiveRecord::Base.uncached do
    res = controller.log_domains(event: 'update', date_to: date_to, date_from: date_from)
  end
end

time_after = Benchmark.realtime do
  ActiveRecord::Base.uncached do
    res = controller.log_domains(event: 'update', date_to: date_to, date_from: date_from)
  end
end

puts "Time for 'before': #{time_before} seconds"
puts "Time for 'after': #{time_after} seconds"
