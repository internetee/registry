class DomainNameserver < ActiveRecord::Base
  belongs_to :domain
  belongs_to :nameserver
end
