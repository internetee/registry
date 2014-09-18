class Country < ActiveRecord::Base
  def to_s
    name
  end
end
