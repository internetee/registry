class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :timeoutable
  # TODO Foreign user will get email with activation link,email,temp-password.
  # After activisation, system should require to change temp password.
  # TODO Estonian id validation

  belongs_to :role
  belongs_to :registrar

  validates :username, :password, presence: true
  validates :identity_code, uniqueness: true, allow_blank: true
  validate :registrar_presence

  before_save :manage_registrar

  attr_accessor :registrar_typeahead

  def to_s
    username
  end

  def registrar_typeahead
    @registrar_typeahead || registrar || nil
  end

  private

  def registrar_presence
    if !admin && !registrar
      errors.add(:registrar, :blank)
    end
  end

  def manage_registrar
    self.registrar = nil if admin?
  end
end
