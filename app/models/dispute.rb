class Dispute < ApplicationRecord
  validates :domain_name, :password, :starts_at, :expires_at, :comment,
            presence: true
  validates_uniqueness_of :domain_name, case_sensitive: true
end
