class Account < ActiveRecord::Base
  include Versions

  belongs_to :registrar, required: true
  has_many :account_activities

  validates :account_type, presence: true

  CASH = 'cash'.freeze

  def activities
    account_activities
  end
end
