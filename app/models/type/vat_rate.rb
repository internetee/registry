module Type
  class VATRate < ActiveRecord::Type::Value
    def type_cast_from_user(value)
      if value.blank?
        nil
      else
        super
      end
    end

    def type_cast_from_database(value)
      BigDecimal(value) * 100 if value
    end

    def type_cast_for_database(value)
      BigDecimal(value) / 100.0 if value
    end
  end
end
