module Epp
  class ExpiredSessions
    attr_reader :sessions

    def initialize(sessions)
      @sessions = sessions
    end

    def clear
      sessions.find_each(&:destroy!)
    end
  end
end
