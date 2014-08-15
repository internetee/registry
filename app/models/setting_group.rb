class SettingGroup < ActiveRecord::Base
  has_many :settings

  accepts_nested_attributes_for :settings
end
