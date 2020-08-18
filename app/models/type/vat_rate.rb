module Type
  class VATRate < ActiveRecord::Type::Decimal
    def deserialize(value)
      super * 100 if value
    end

    def serialize(value)
      super / 100.0 if value
    end
  end
end
