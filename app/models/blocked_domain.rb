class BlockedDomain < ActiveRecord::Base
  include Versions

  after_initialize -> { self.names = [] if names.nil? }
end
