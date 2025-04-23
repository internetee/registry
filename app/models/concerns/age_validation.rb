module AgeValidation
  extend ActiveSupport::Concern

  def underage?
    case ident_type
    when 'birthday'
      underage_by_birthday?
    when 'priv'
      underage_by_estonian_id?
    else
      false
    end
  end

  private

  def underage_by_birthday?
    birth_date = Date.parse(ident)
    calculate_age(birth_date) < 18
  rescue ArgumentError
    true
  end

  def underage_by_estonian_id?
    return false unless estonian_id?

    birth_date = parse_estonian_id_birth_date(ident)
    calculate_age(birth_date) < 18
  rescue ArgumentError
    true
  end

  def estonian_id?
    ident_country_code == 'EE' && ident.match?(/^\d{11}$/)
  end

  def calculate_age(birth_date)
    ((Time.zone.now - birth_date.to_time) / 1.year.seconds).floor
  end

  def parse_estonian_id_birth_date(id_code)
    century_number = id_code[0].to_i
    year_digits = id_code[1..2]
    month = id_code[3..4]
    day = id_code[5..6]
    
    birth_year = case century_number
                 when 1, 2 then "18#{year_digits}"
                 when 3, 4 then "19#{year_digits}"
                 when 5, 6 then "20#{year_digits}"
                 else
                   raise ArgumentError, "Invalid century number in Estonian ID"
                 end
                 
    Date.parse("#{birth_year}-#{month}-#{day}")
  end
end
