class User < ActiveRecord::Base
  # TODO Foreign user will get email with activation link,email,temp-password.
  # After activisation, system should require to change temp password.
  # TODO Estonian id validation

  belongs_to :role
end
