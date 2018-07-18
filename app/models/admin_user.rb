class AdminUser < User
  validates :username, :country_code, :roles, presence: true
  validates :identity_code, uniqueness: true, allow_blank: true
  validates :identity_code, presence: true, if: -> { country_code == 'EE' }
  validates :email, presence: true
  validates :password, :password_confirmation, presence: true, if: :new_record?
  validates :password_confirmation, presence: true, if: :encrypted_password_changed?
  validate :validate_identity_code, if: -> { country_code == 'EE' }

  ROLES = %w(user customer_service admin) # should not match to api_users roles

  devise :database_authenticatable, :trackable, :validatable, :timeoutable,
         authentication_keys: [:username]

  def self.min_password_length
    Devise.password_length.min
  end

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
