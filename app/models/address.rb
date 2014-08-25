class Address < ActiveRecord::Base
  belongs_to :contact
  belongs_to :country

  class << self
    def extract_attributes(ah, _type = :create)
      address_hash = {}
      address_hash = ({
        country_id: Country.find_by(iso: ah[:cc]).try(:id),
        city: ah[:city],
        street: ah[:street][0],
        street2: ah[:street][1],
        street3: ah[:street][2],
        zip: ah[:pc]
      }) if ah.is_a?(Hash)

      address_hash.delete_if { |_k, v| v.nil? }
    end
  end
end
