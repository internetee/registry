class ObjectVersionsParser
  def initialize(version)
    @version = version
  end

  def parse
    model = @version.item_type.constantize
    attributes = only_present_fields(model)
    history_object = model.new(attributes)
    attach_existing_fields(history_object) unless @version.event == 'destroy'

    history_object
  end

  private

  def attach_existing_fields(history_object)
    @version.object_changes.to_h.each do |key, value|
      method_name = "#{key}=".to_sym
      history_object.public_send(method_name, value.last) if history_object.respond_to?(method_name)
    end
  end

  def only_present_fields(model)
    field_names = model.column_names
    @version.object.to_h.select { |key, _value| field_names.include?(key) }
  end
end
