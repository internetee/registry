module EppErrors
  extend ActiveSupport::Concern

  def construct_epp_errors
    epp_errors = []
    errors.messages.each do |attr, errors|
      attr = attr.to_s.split('.')[0].to_sym
      next if attr == :epp_errors

      if self.class.reflect_on_association(attr)
        epp_errors << collect_child_errors(attr)
      end

      if self.class.reflect_on_aggregation(attr)
        aggregation = send(attr)
        epp_errors << collect_aggregation_errors(aggregation)
        next
      end

      epp_errors << collect_parent_errors(attr, errors)
    end

    errors[:epp_errors] = epp_errors
    errors[:epp_errors].flatten!
  end

  def collect_parent_errors(attr, errors)
    errors = [errors] if errors.is_a?(String)

    epp_errors = []
    errors.each do |err|
      code, value = find_epp_code_and_value(err)
      next unless code
      msg = attr.to_sym == :base ? err : "#{err} [#{attr}]"
      epp_errors << { code: code, msg: msg, value: value }
    end
    epp_errors
  end

  def collect_child_errors(attr)
    macro = self.class.reflect_on_association(attr).macro
    multi = [:has_and_belongs_to_many, :has_many]
    # single = [:belongs_to, :has_one]

    epp_errors = []
    send(attr).each do |x|
      x.errors.messages.each do |attribute, errors|
        epp_errors << x.collect_parent_errors(attribute, errors)
      end
    end if multi.include?(macro)

    epp_errors
  end

  def collect_aggregation_errors(aggregation)
    epp_errors = []

    aggregation.errors.details.each do |attr, error_details|
      error_details.each do |error_detail|
        aggregation.class.epp_code_map.each do |epp_code, attr_to_error|
          epp_code_found = attr_to_error.any? { |i| i == [attr, error_detail[:error]] }

          next unless epp_code_found

          message = aggregation.errors.generate_message(attr, error_detail[:error], error_detail)
          message = aggregation.errors.full_message(attr, message)

          if attr != :base
            message = "#{aggregation.model_name.human} #{message.camelize(:lower)}"
          end

          epp_errors << { code: epp_code, msg: message }
        end
      end
    end

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
