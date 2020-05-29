# Store console and rake changes in versions
if defined?(::Rails::Console)
  PaperTrail.request.whodunnit = "console-#{`whoami`.strip}"
elsif File.basename($PROGRAM_NAME) == 'rake'
  # rake username does not work when spring enabled
  PaperTrail.request.whodunnit = "rake-#{`whoami`.strip} #{ARGV.join ' '}"
end

class PaperSession
  class << self
    attr_writer :session
    def session
      @session ||= Time.zone.now.to_s(:db)
    end
  end
end
