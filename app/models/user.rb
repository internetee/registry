class User < ActiveRecord::Base
  include Versions # version/user_version.rb
  devise :trackable, :timeoutable

  attr_accessor :phone

  def string
    "#{self.id}-#{self.class}: #{self.username}"
  end

end
