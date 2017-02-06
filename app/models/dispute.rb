class Dispute < ActiveRecord::Base
  belongs_to :domain, required: true

  validates :expire_date, :password, :comment, presence: true
  validates :domain, uniqueness: true
  validate :validate_expire_date_past

  alias_attribute :create_time, :created_at

  delegate :name, to: :domain, prefix: true, allow_nil: true

  def self.latest_on_top
    order(create_time: :desc)
  end

  def domain_name=(value)
    self.domain = Domain.find_by(name: value)
  end

  private

  def validate_expire_date_past
    return if expire_date.nil?
    errors.add(:expire_date, :past) if expire_date.past?
  end
end
