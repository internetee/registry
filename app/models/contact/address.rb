class Contact
  class Address
    attr_reader :street, :zip, :city, :state, :country_code

    def initialize(street, zip, city, state, country_code)
      @street = street
      @zip = zip
      @city = city
      @state = state
      @country_code = country_code
    end

    def ==(other)
      (street == other.street) &&
        (zip == other.zip) &&
        (city == other.city) &&
        (state == other.state) &&
        (country_code == other.country_code)
    end
  end
end
