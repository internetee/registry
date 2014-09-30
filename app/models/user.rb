class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :timeoutable
  # TODO Foreign user will get email with activation link,email,temp-password.
  # After activisation, system should require to change temp password.
  # TODO Estonian id validation

  belongs_to :role
  belongs_to :registrar
  belongs_to :country

  validates :username, :password, presence: true
  validates :identity_code, uniqueness: true, allow_blank: true
  validates :identity_code, presence: true, if: -> { country.iso == 'EE' }
  validates :email, presence: true, if: -> { country.iso == 'LV' }
  validates :registrar, presence: true, if: -> { !admin }

  before_save -> { self.registrar = nil if admin? }

  attr_accessor :registrar_typeahead

  def to_s
    username
  end

  def registrar_typeahead
    @registrar_typeahead || registrar || nil
  end
end
