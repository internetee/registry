class BlockedDomain < ActiveRecord::Base
  include Versions
validates :name, domain_name: true, uniqueness: true

  after_initialize -> { self.names = [] if names.nil? }
end
