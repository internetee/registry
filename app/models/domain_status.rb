class DomainStatus < ActiveRecord::Base
  # Domain statuses are stored as settings
  include EppErrors

  EPP_ATTR_MAP = {
    setting: 'status'
  }

  belongs_to :domain
  belongs_to :setting

  delegate :value, :code, to: :setting

  validates :setting, uniqueness: { scope: :domain_id }

  def setting_uniqueness

  end

  def epp_code_map
    {
      '2302' => [[:setting, :taken]]
    }
  end
end
