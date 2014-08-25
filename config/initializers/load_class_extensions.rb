Dir[File.join(Rails.root, 'lib', 'ext', '*.rb')].each { |x| require x }
