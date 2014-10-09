class Setting < ActiveRecord::Base
  belongs_to :setting_group
  has_many :domain_statuses
  has_many :domains, through: :domain_statuses
  validates :code, uniqueness: { scope: :setting_group_id }

  #dnskeys
  DS_ALGORITHM = 'ds_algorithm'
  ALLOW_DS_DATA = 'allow_ds_data'
  ALLOW_DS_DATA_WITH_KEYS = 'allow_ds_data_with_keys'
  ALLOW_KEY_DATA = 'allow_key_data'
end
