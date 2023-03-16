class Account < ApplicationRecord
  include Versions

  belongs_to :registrar, required: true
  has_many :account_activities

  validates :account_type, presence: true

  CASH = 'cash'.freeze

  def activities
    account_activities
  end

  def as_csv_row
    [id, balance, currency, registrar]
  end

  def self.ransackable_associations(auth_object = nil)
    super
  end

  def self.ransackable_attributes(auth_object = nil)
    super
  end

  def self.csv_header
    %w[Id Balance Currency Registrar]
  end
end
