Dir[File.join(Rails.root, "app", "validators", "*.rb")].each {|x| require x }
