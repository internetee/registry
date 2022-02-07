# frozen_string_literal: true

namespace :disputes do
  desc 'Check closed disputes with expired_at in the Past'
  task check_closed: :environment do
    DisputeStatusUpdateJob.perform_now(include_closed: true)
  end
end
