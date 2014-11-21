class Country < ActiveRecord::Base
  def to_s
    name
  end

  class << self
    def estonia
      find_by(iso: 'EE')
    end
  end
end
