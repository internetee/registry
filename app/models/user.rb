class User < ApplicationRecord
  include Versions # version/user_version.rb

  has_many :actions, dependent: :restrict_with_exception

  attr_accessor :phone

  self.ignored_columns = %w[legacy_id]

  def id_role_username
    "#{self.id}-#{self.class}: #{self.username}"
  end

end
