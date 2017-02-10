class Dispute < ActiveRecord::Base
  include Concerns::Dispute::Searchable

  self.auto_html5_validation = false

  validates :domain_name, :password, :expire_date, :comment, presence: true
  validates :domain_name, uniqueness: true
  validate :validate_expire_date_past, on: :admin

  alias_attribute :create_time, :created_at
  alias_attribute :update_time, :updated_at

  def self.latest_on_top
    order(create_time: :desc)
  end

  def self.expired
    where('expire_date < ?', Time.zone.today)
  end

  def self.delete_expired
    expired.delete_all
  end

  def generate_password
    self.password = SecureRandom.hex
  end

  private

  def validate_expire_date_past
    return if expire_date.nil?
    errors.add(:expire_date, :past) if expire_date.past?
  end
end
