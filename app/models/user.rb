class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :timeoutable
  # TODO Foreign user will get email with activation link,email,temp-password.
  # After activisation, system should require to change temp password.
  # TODO Estonian id validation

  belongs_to :role
end
