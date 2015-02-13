class User < ActiveRecord::Base
  include Versions # version/user_version.rb
end
