namespace :api_users do
  desc 'Backfill subject from identity_code for ApiUsers (idempotent)'
  task backfill_subject: :environment do
    result = ApiUsers::SubjectBackfill.run
    puts "ApiUser subject backfill: updated=#{result[:updated]} skipped=#{result[:skipped]}"
  end
end
