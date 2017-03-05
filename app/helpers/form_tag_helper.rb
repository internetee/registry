module FormTagHelper
  def legal_document_field_tag(name, options = {})
    options[:data] = { legal_document: true }
    options[:accept] = legal_document_types unless options[:accept]

    file_field_tag(name, options)
  end
end
