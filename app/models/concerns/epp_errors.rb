module EppErrors
  extend ActiveSupport::Concern

  def construct_epp_errors
    epp_errors = []
    errors.messages.each do |key, values|
      key = key.to_s.split('.')[0].to_sym
      next if key == :epp_errors

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
        code = err[:code] || find_epp_code(err[:msg])
        next unless code
        err_msg = { code: code, msg: err[:msg] }
        err_msg[:value] = { val: err[:val], obj: err[:obj] } if err[:val]
        epp_errors << err_msg
      else
        next unless code = find_epp_code(err)
        err = { code: code, msg: err }

        # if the key represents relations, skip value
        unless self.class.reflect_on_association(key)
          err[:value] = { val: send(key), obj: self.class::EPP_ATTR_MAP[key] }
        end

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
    epp_code_map.each do |code, values|
      values.each do |x|
        t = errors.generate_message(*x) if x.is_a?(Array)
        t = x if x.is_a?(String)
        return code if t == msg
      end
    end
    nil
  end

  def add_epp_error(code, obj, val, msg)
    errors[:epp_errors] ||= []
    t = errors.generate_message(*msg) if msg.is_a?(Array)
    t = msg if msg.is_a?(String)
    errors[:epp_errors] << { code: code, msg: t, value: { val: val, obj: obj } }
  end
end
