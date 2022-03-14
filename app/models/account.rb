class Account < ApplicationRecord
  extend ToCsv
  include Versions

  belongs_to :registrar, required: true
  has_many :account_activities

  validates :account_type, presence: true

  CASH = 'cash'

  def activities
    account_activities
  end

  def as_csv_row
    [id, balance, currency, registrar]
  end

  def self.csv_header
    ['Id', 'Balance', 'Currency', 'Registrar']
  end
end
