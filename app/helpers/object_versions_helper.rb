module ObjectVersionsHelper
  CSV_HEADER = ['Name', 'Registrant', 'Registrar', 'Action', 'Created at'].freeze

  def attach_existing_fields(version, new_object)
    version.object_changes.to_h.each do |key, value|
      method_name = "#{key}=".to_sym
      new_object.public_send(method_name, event_value(version, value)) if new_object.respond_to?(method_name)
    end
  end

  def only_present_fields(version, model)
    field_names = model.column_names
    version.object.to_h.select { |key, _value| field_names.include?(key) }
  end

  def csv_generate(model, header)
    CSV.generate do |csv|
      csv << header
      @versions.each do |version|
        attributes = only_present_fields(version, model)
        history_object = model.new(attributes)
        attach_existing_fields(version, history_object) unless version.event == 'destroy'

        csv << create_row(history_object, version)
      end
    end
  end

  private

  def event_value(version, val)
    version.event == 'destroy' ? val.first : val.last
  end

  def registrant_name(domain, version)
    if domain.registrant
      domain.registrant.name
    else
      contact = Contact.all_versions_for([domain.registrant_id], version.created_at).first
      if contact.nil? && ver = Version::ContactVersion.where(item_id: domain.registrant_id).last
        merged_obj = ver.object_changes.to_h.each_with_object({}) {|(k,v), o| o[k] = v.last }
        result = ver.object.to_h.merge(merged_obj)&.slice(*Contact&.column_names)
        contact = Contact.new(result)
      end
      contact.try(:name) || 'Deleted'
    end
  end

  def create_row(history_object, version)
    if history_object.is_a?(Domain)
      domain_history_row(history_object, version)
    else
      contact_history_row(history_object, version)
    end
  end

  def contact_history_row(history_object, version)
    name = history_object.name
    code = history_object.code
    ident = ident_for(history_object)
    registrar = history_object.registrar
    event = version.event
    created_at = version.created_at.to_formatted_s(:db)
    [name, code, ident, registrar, event, created_at]
  end

  def domain_history_row(history_object, version)
    name = history_object.name
    registrant = registrant_name(history_object, version)
    registrar = history_object.registrar
    event = version.event
    created_at = version.created_at.to_formatted_s(:db)
    [name, registrant, registrar, event, created_at]
  end
end
