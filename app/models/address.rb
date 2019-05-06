class Address
  attr_reader :parts

  def initialize(parts)
    @parts = parts
  end

  def street
    parts[:street]
  end

  def zip
    parts[:zip]
  end

  def city
    parts[:city]
  end

  def state
    parts[:state]
  end

  def country
    parts[:country]
  end

  def ==(other)
    parts == other.parts
  end

  def to_s
    ordered_parts = [street, city, state, zip, country]
    ordered_parts.reject(&:blank?).compact.join(', ')
  end
end