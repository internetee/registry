module ObjectVersionsHelper
  def attach_existing_fields(version, new_object)
    version.object_changes.to_h.each do |k, v|
      method_name = "#{k}=".to_sym
      if new_object.respond_to?(method_name)
        new_object.public_send(method_name, v.last)
      end
    end
  end
end
