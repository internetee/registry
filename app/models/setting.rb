class Setting < ActiveRecord::Base
  belongs_to :setting_group
  validates :code, uniqueness: { scope: :setting_group_id }
end
