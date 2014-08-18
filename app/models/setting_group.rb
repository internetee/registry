class SettingGroup < ActiveRecord::Base
  has_many :settings

  accepts_nested_attributes_for :settings

  DOMAIN_VALIDATION_CODE = 'domain_validation'

  def get(key)
    s = settings.find_by(code: key.to_s)
    s.try(:value)
  end
end
