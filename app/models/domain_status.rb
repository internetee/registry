class DomainStatus < ActiveRecord::Base
  belongs_to :domain
  belongs_to :setting
end
