class Dispute < ActiveRecord::Base
  include Concerns::Dispute::Searchable

  self.auto_html5_validation = false

  validates :domain_name, :password, :expire_date, :comment, presence: true
  validates :domain_name, uniqueness: true

  with_options on: :admin do
    validate :validate_expire_date_past
    validate :validate_domain_name
  end

  alias_attribute :create_time, :created_at
  alias_attribute :update_time, :updated_at

  def self.latest_on_top
    order(create_time: :desc)
  end

  def self.expired
    where('expire_date < ?', Time.zone.today)
  end

  def self.close_expired
    expired.each do |dispute|
      dispute.close
    end
  end

  def generate_password
    self.password = SecureRandom.hex
  end

  def close
    Disputes::Close.new(dispute: self).close
  end

  private

  def validate_expire_date_past
    return if expire_date.nil?
    errors.add(:expire_date, :past) if expire_date.past?
  end

  def validate_domain_name
    return unless domain_name

    zone = domain_name.split('.').last
    supported_zone = DNS::Zone.origins.include?(zone)

    errors.add(:domain_name, :unsupported_zone) unless supported_zone
  end
end
