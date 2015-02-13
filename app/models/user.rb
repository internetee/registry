class User < ActiveRecord::Base
  include Versions # version/user_version.rb
  devise :trackable, :timeoutable
end
