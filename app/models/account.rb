class Account < ActiveRecord::Base
  belongs_to :registrar
  has_many :account_activities

  CASH = 'cash'

  def activities
    account_activities
  end
end
