module ObjectVersionsHelper
  def attach_existing_fields_audit(version, new_object)
    version.diff.to_h.each do |key, value|
      method_name = "#{key}=".to_sym
      if new_object.respond_to?(method_name)
        new_object.public_send(method_name, value)
      end
    end
  end

  def only_present_fields_audit(version, model)
    field_names = model.column_names
    old_fields = version.old_value.select { |key, _value| field_names.include?(key) }
    new_fields = version.new_value.select { |key, _value| field_names.include?(key) }
    old_fields.merge(new_fields)
  end
end
