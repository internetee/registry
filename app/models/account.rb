class Account < ActiveRecord::Base
  include Versions
  belongs_to :registrar
  has_many :account_activities

  validates :account_type, presence: true

  CASH = 'cash'

  def activities
    account_activities
  end
end
