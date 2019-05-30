module ObjectVersionsHelper
  def attach_existing_fields(version, new_object)
    version.object_changes.to_h.each do |key, value|
      method_name = "#{key}=".to_sym
      new_object.public_send(method_name, value.last) if new_object.respond_to?(method_name)
    end
  end

  def only_present_fields(version, model)
    field_names = model.column_names
    version.object.to_h.select { |key, _value| field_names.include?(key) }
  end
end
