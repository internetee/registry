class DomainAutoRenewal < ApplicationRecord
  include Versions

  AWAITING_FUNDS = 'awaiting_funds'.freeze
  GRACE = 'grace'.freeze
  COMPLETED = 'completed'.freeze
  REVERSED = 'reversed'.freeze
  FUNDING_FAILED = 'funding_failed'.freeze
  CANCELLED = 'cancelled'.freeze
  STATES = [AWAITING_FUNDS, GRACE, COMPLETED, REVERSED, FUNDING_FAILED, CANCELLED].freeze
  OPEN_STATES = [AWAITING_FUNDS, GRACE].freeze

  INSUFFICIENT_FUNDS = 'insufficient_funds'.freeze
  RENEW_PROHIBITED = 'renew_prohibited'.freeze
  MISSING_PRICE = 'missing_price'.freeze

  RGP_AUTO_RENEW_PERIOD = 'autoRenewPeriod'.freeze
  CANCELLATION_PERIOD_DAYS = 15
  RENEWAL_PERIOD_YEARS = 1

  belongs_to :domain, optional: true
  belongs_to :registrar
  belongs_to :account
  belongs_to :price, class_name: 'Billing::Price', optional: true
  belongs_to :charge_activity, class_name: 'AccountActivity', optional: true
  belongs_to :refund_activity, class_name: 'AccountActivity', optional: true

  # The column has a DB default, but Rails does not read it back after INSERT.
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  scope :open_cycles, -> { where(state: OPEN_STATES) }
  scope :awaiting_funds, -> { where(state: AWAITING_FUNDS) }
  scope :in_grace, -> { where(state: GRACE) }
  scope :due_for_closing, lambda { |now = Time.zone.now|
    open_cycles.where('cancellation_deadline_at <= ?', now)
  }

  validates :state, inclusion: { in: STATES }
  validates :domain_name, :original_expire_at, :cancellation_deadline_at, presence: true

  def self.cancellation_deadline_for(original_expire_at)
    original_expire_at.advance(days: CANCELLATION_PERIOD_DAYS)
  end

  def open?
    OPEN_STATES.include?(state)
  end

  def terminal?
    !open?
  end

  def awaiting_funds?
    state == AWAITING_FUNDS
  end

  def grace?
    state == GRACE
  end

  def reversed?
    state == REVERSED
  end

  def grace_active?(at = Time.zone.now)
    grace? && at < cancellation_deadline_at
  end

  def reversible?(at = Time.zone.now)
    grace_active?(at)
  end

  def protocol_state(at = Time.zone.now)
    case state
    when AWAITING_FUNDS then 'fundingRetry'
    when GRACE then grace_active?(at) ? RGP_AUTO_RENEW_PERIOD : 'completed'
    when COMPLETED then 'completed'
    when REVERSED then 'reversed'
    when FUNDING_FAILED then 'fundingFailed'
    when CANCELLED then 'cancelled'
    end
  end

  def as_protocol_json(at = Time.zone.now)
    {
      id: uuid,
      state: protocol_state(at),
      original_expire_time: original_expire_at.iso8601,
      expire_time: renewed_expire_at&.iso8601,
      cancellation_deadline: cancellation_deadline_at.iso8601,
      attempts: attempts_count
    }
  end

end
