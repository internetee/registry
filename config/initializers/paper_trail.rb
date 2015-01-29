# the following line is required for PaperTrail >= 4.0.0 with Rails
PaperTrail::Rails::Engine.eager_load!

PaperTrail::Version.module_eval do
  self.abstract_class = true
end

# Store console and rake changes in versions
if defined?(::Rails::Console)
  PaperTrail.whodunnit = "#{`whoami`.strip}: console"
elsif File.basename($PROGRAM_NAME) == "rake"
  PaperTrail.whodunnit = "#{`whoami`.strip}: rake #{ARGV.join ' '}"
end

