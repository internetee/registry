require 'benchmark'

namespace :locked_domains do

  # Add new status instruction!
  # First run `rake locked_domains:add_new_status`
  # and then after finish first task run `rake locked_domains:remove_old_status`
  desc 'Add serverObjUpdateProhibited for locked domains'
  task add_new_status: :environment do
    time = Benchmark.realtime do
      ReplaceUpdToObjUpdProhibitedJob.perform_later('add')
    end
    puts "Time is #{time.round(2)} for add serverObjUpdateProhibited status for locked domains"
  end

  desc 'Remove serverUpdateProhibited from locked domains'
  task remove_old_status: :environment do
    time = Benchmark.realtime do
      ReplaceUpdToObjUpdProhibitedJob.perform_later('remove')
    end
    puts "Time is #{time.round(2)} for remove serverUpdateProhibited for locked domains"
  end

  # Rollback instruction!
  # First run `rake locked_domains:rollback_remove_old_status` 
  # and then after finish first task run `rake locked_domains:rollback_add_new_status`
  desc 'Rollback remove old serverUpdateProhibited for locked domains'
  task rollback_remove_old_status: :environment do
    time = Benchmark.realtime do
      ReplaceUpdToObjUpdProhibitedJob.perform_later('add', true)
    end
    puts "Time is #{time.round(2)} for add serverObjUpdateProhibited status for locked domains"
  end

  desc 'Rollback add new serverObjUpdateProhibited for locked domains'
  task rollback_add_new_status: :environment do
    time = Benchmark.realtime do
      ReplaceUpdToObjUpdProhibitedJob.perform_later('remove', true)
    end
    puts "Time is #{time.round(2)} for add serverObjUpdateProhibited status for locked domains"
  end
end
