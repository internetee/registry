class DomainContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :domain
end
