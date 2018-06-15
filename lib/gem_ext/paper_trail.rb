# the following line is required for PaperTrail >= 4.0.0 with Rails
PaperTrail::Rails::Engine.eager_load!

PaperTrail::Version.module_eval do
  self.abstract_class = true
end

# Store console and rake changes in versions
if defined?(::Rails::Console) || File.basename($PROGRAM_NAME).split(' ').first == 'spring'
  PaperTrail.whodunnit = "console-#{`whoami`.strip}"
elsif File.basename($PROGRAM_NAME) == 'rake'
  # rake username does not work when spring enabled
  PaperTrail.whodunnit = "rake-#{`whoami`.strip} #{ARGV.join ' '}"
end

class PaperSession
  class << self
    attr_writer :session
    def session
      @session ||= Time.zone.now.to_s(:db)
    end
  end
end
