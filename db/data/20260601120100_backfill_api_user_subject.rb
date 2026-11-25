class BackfillApiUserSubject < ActiveRecord::Migration[6.1]
  def up
    result = ApiUsers::SubjectBackfill.run
    say "ApiUser subject backfill: updated=#{result[:updated]} skipped=#{result[:skipped]}"
  end

  def down
    ApiUser.where.not(subject: [nil, '']).update_all(subject: nil)
  end
end
