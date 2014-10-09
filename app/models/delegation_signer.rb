class DelegationSigner < ActiveRecord::Base
  has_many :dnskeys
end
