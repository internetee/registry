# frozen_string_literal: true

require_relative "../../config/environment"

# Any benchmarking setup goes here...



Benchmark.ips do |x|
  x.report("before") do
    date_to = Date.strptime("10.23", '%m.%y').end_of_month
    date_from = Date.strptime("01.22", '%m.%y').end_of_month

    res = Repp::V1::StatsController.new.log_domains(event: 'update', date_to: date_to, date_from: date_from)
    puts res.size
  end
  x.report("after") do
    date_to = Date.strptime("10.23", '%m.%y').end_of_month
    date_from = Date.strptime("01.22", '%m.%y').end_of_month

    res = Repp::V1::StatsController.new.log_domains2(event: 'update', date_to: date_to, date_from: date_from)
    puts res.size
  end

  x.compare!
end
