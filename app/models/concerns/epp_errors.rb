module EppErrors
  extend ActiveSupport::Concern
  included do
    attr_accessor :epp_errors
  end

  def construct_epp_errors
    epp_errors = ActiveModel::Errors.new(self)
    errors.each do |error|
      attr = error.attribute.to_s.split('.')[0].to_sym
      next if attr == :epp_errors

      if self.class.reflect_on_association(attr)
        collect_child_errors(attr).each do |child_error|
          epp_errors.import child_error
        end
      end

      if self.class.reflect_on_aggregation(attr)
        aggregation = send(attr)
        collect_aggregation_errors(aggregation).each do |aggregation_error|
          epp_errors.import aggregation_error
        end
        next
      end
      collect_parent_errors(attr, error.message).each do |parent_error|
        epp_errors.import parent_error
      end
    end
    epp_errors.each { |epp_error| errors.import epp_error }
    errors
  end

  def collect_parent_errors(attr, errors)
    errors = [errors] if errors.is_a?(String)

    epp_errors = ActiveModel::Errors.new(self)
    errors.each do |err|
      code, value = find_epp_code_and_value(err)
      next unless code

      msg = attr.to_sym == :base ? err : "#{err} [#{attr}]"
      epp_errors.add(attr, code: code, msg: msg, value: value)
    end
    epp_errors
  end

  def collect_child_errors(attr)
    macro = self.class.reflect_on_association(attr).macro
    multi = [:has_and_belongs_to_many, :has_many]

    epp_errors = ActiveModel::Errors.new(self)

    if multi.include?(macro)
      send(attr).each do |x|
        x.errors.each do |error|
          x.collect_parent_errors(error.attribute, error.message).each do |parent_error|
            epp_errors.import parent_error
          end
        end
      end
    end

    epp_errors
  end

  def collect_aggregation_errors(aggregation)
    epp_errors = ActiveModel::Errors.new(self)

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

          epp_errors.add(attr, code: epp_code, msg: message)
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
  rescue NameError
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
    t = errors.generate_message(*msg) if msg.is_a?(Array)
    t = msg if msg.is_a?(String)
    err = { code: code, msg: t }
    val = check_for_status(code, obj, val)
    err[:value] = { val: val, obj: obj } if val.present?
    errors.add(:epp_errors, **err)
  end

  def check_for_status(code, obj, val)
    if code == '2304' && val.present? && val == DomainStatus::SERVER_DELETE_PROHIBITED &&
       obj == 'status'
      DomainStatus::PENDING_UPDATE
    else
      val
    end
  end
end
