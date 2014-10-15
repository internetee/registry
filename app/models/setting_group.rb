class SettingGroup < ActiveRecord::Base
  has_many :settings

  accepts_nested_attributes_for :settings

  validates :code, uniqueness: true

  def setting(key)
    settings.find_by(code: key.to_s)
  end

  class << self
    def domain_validation
      find_by(code: 'domain_validation')
    end

    def domain_general
      find_by(code: 'domain_general')
    end

    def dnskeys
      find_by(code: 'dnskeys')
    end
  end
end
