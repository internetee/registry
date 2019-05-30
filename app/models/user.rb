class User < ActiveRecord::Base
  include Versions # version/user_version.rb

  has_many :actions, dependent: :restrict_with_exception

  attr_accessor :phone

  def id_role_username
    "#{id}-#{self.class}: #{username}"
  end
end
