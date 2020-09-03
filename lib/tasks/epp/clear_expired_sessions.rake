namespace :epp do
  desc 'Clear expired EPP sessions'

  task clear_expired_sessions: :environment do
    Epp::ExpiredSessions.new(EppSession.expired).clear
  end
end
