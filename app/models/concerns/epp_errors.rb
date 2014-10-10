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

      epp_errors << collect_parent_errors(values)
    end

    errors[:epp_errors] = epp_errors
    errors[:epp_errors].flatten!
  end

  def collect_parent_errors(values)
    epp_errors = []
    values = [values] if values.is_a?(String)

    values.each do |err|
      code, value = find_epp_code_and_value(err)
      next unless code
      epp_errors << { code: code, msg: err, value: value }
    end
    epp_errors
  end

  def collect_child_errors(key)
    macro = self.class.reflect_on_association(key).macro
    multi = [:has_and_belongs_to_many, :has_many]
    single = [:belongs_to, :has_one]

    epp_errors = []
    send(key).each do |x|
      x.errors.messages.each do |_key, values|
        epp_errors << x.collect_parent_errors(values)
      end
    end if multi.include?(macro)

    epp_errors
  end

  def find_epp_code_and_value(msg)
    epp_code_map.each do |code, values|
      values.each do |x|
        msg_args, value = construct_msg_args_and_value(x)
        t = errors.generate_message(*msg_args)
        return [code, value] if t == msg
      end
    end
    nil
  end

  def construct_msg_args_and_value(epp_error_args)
    args = {}
    args = epp_error_args.delete_at(-1) if epp_error_args.last.is_a?(Hash)
    msg_args = epp_error_args

    value = args.delete(:value) if args.key?(:value)

    interpolation = args[:interpolation] || args

    msg_args << interpolation

    [msg_args, value]
  end

  def add_epp_error(code, obj, val, msg)
    errors[:epp_errors] ||= []
    t = errors.generate_message(*msg) if msg.is_a?(Array)
    t = msg if msg.is_a?(String)
    err = { code: code, msg: t }
    err[:value] = { val: val, obj: obj } if val.present?
    errors[:epp_errors] << err
  end
end
