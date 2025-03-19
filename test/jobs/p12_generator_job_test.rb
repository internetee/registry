require 'test_helper'

class P12GeneratorJobTest < ActiveJob::TestCase
  test "ensures only one job runs at a time" do
    Sidekiq::Testing.inline!

    api_user = users(:api_bestnames)
    
    thread1 = Thread.new do
      P12GeneratorJob.perform_later(api_user.id)
    end
    
    sleep(2)

    thread2 = Thread.new do
      P12GeneratorJob.perform_later(api_user.id)
    end

    thread1.join
    thread2.join
    
  ensure
    Sidekiq::Testing.fake!
  end
end
