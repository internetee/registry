class Setting < ActiveRecord::Base
  belongs_to :setting_group
  has_many :domain_statuses
  has_many :domains, through: :domain_statuses
  validates :code, uniqueness: { scope: :setting_group_id }
end
