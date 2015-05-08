class AdminUser < User
  validates :username, :password, :country_code, :roles, presence: true
  validates :identity_code, uniqueness: true, allow_blank: true
  validates :identity_code, presence: true, if: -> { country_code == 'EE' }
  validates :email, presence: true 

  validate :validate_identity_code, if: -> { country_code == 'EE' }

  ROLES = %w(user customer_service admin)

  def to_s
    username
  end

  def country
    Country.new(country_code)
  end

  private

  def validate_identity_code
    return unless identity_code.present?
    code = Isikukood.new(identity_code)
    errors.add(:identity_code, :invalid) unless code.valid?
  end
end
