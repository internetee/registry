class ApplicationJob < ActiveJob::Base
  discard_on NoMethodError
  queue_as :default
end
