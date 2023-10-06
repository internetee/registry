require_relative "../../config/environment"
require 'benchmark/ips'

Benchmark.ips do |x|
  x.warmup = 2
  x.time = 5

  controller = Repp::V1::StatsController.new
  controller.params = ActionController::Parameters.new(
    q: {
      end_date: '10.23',
      compare_to_end_date: '10.22'
    }
  )
  # date_to = Date.strptime("10.23", '%m.%y').end_of_month
  # date_from = Date.strptime("01.22", '%m.%y').end_of_month

  controller.set_date_params  # Вызывает метод, который устанавливает переменные экземпляра
  
  x.report("before") do
    ActiveRecord::Base.uncached do
      res = controller.market_share_growth_rate
    end
  end

  x.report("after") do
    ActiveRecord::Base.uncached do
      res = controller.market_share_growth_rate2
    end
  end

  x.compare!
end