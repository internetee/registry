class Country < ActiveRecord::Base
  include Versions # version/country_version.rb

  validates :name, presence: true

  def to_s
    name
  end

  class << self
    def estonia
      find_by(iso: 'EE')
    end
  end
end
