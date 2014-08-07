module EppErrors
  extend ActiveSupport::Concern

  def construct_epp_errors
    epp_errors = []
    errors.messages.each do |key, values|
      if self.class.reflect_on_association(key)
        epp_errors << collect_child_errors(key)
      end

      epp_errors << collect_parent_errors(key, values)
    end

    errors[:epp_errors] = epp_errors
    errors[:epp_errors].flatten!
  end

  def collect_parent_errors(key, values)
    epp_errors = []
    values = [values] if values.is_a?(String)

    values.each do |err|
      if err.is_a?(Hash)
        next unless code = find_epp_code(err[:msg])
        epp_errors << {code: code, msg: err[:msg], value: {val: err[:val], obj: err[:obj]}}
      else
        next unless code = find_epp_code(err)
        err = {code: code, msg: err}
        err[:value] = {val: send(key), obj: self.class::EPP_OBJ} unless self.class.reflect_on_association(key)
        epp_errors << err
      end
    end
    epp_errors
  end

  def collect_child_errors(key)
    macro = self.class.reflect_on_association(key).macro
    multi = [:has_and_belongs_to_many, :has_many]
    single = [:belongs_to, :has_one]

    epp_errors = []
    send(key).each do |x|
      x.errors.messages.each do |key, values|
        epp_errors << x.collect_parent_errors(key, values)
      end
    end if multi.include?(macro)

    epp_errors
  end

  def find_epp_code(msg)
    self.class::EPP_CODE_MAP.each do |code, values|
      return code if values.include?(msg)
    end
    nil
  end
end
