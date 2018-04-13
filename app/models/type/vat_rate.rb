module Type
  class VATRate < ActiveRecord::Type::Decimal
    def type_cast_from_database(value)
      super * 100 if value
    end

    def type_cast_for_database(value)
      super / 100.0 if value
    end
  end
end
