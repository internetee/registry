class SettingGroup < ActiveRecord::Base
  has_many :settings

  accepts_nested_attributes_for :settings

  def setting(key)
    settings.find_by(code: key.to_s)
  end

  class << self
    def domain_validation
      find_by(code: 'domain_validation')
    end
  end
end
