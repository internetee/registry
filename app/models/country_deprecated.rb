class CountryDeprecated < ActiveRecord::Base
  self.table_name = "countries"

  def to_s
    name
  end

  class << self
    def estonia
      find_by(iso: 'EE')
    end
  end
end
