module FormHelper
  def legal_document_field(object_name, method, options = {})
    options[:data] = { legal_document: true }
    options[:accept] = legal_document_types unless options[:accept]

    file_field(object_name, method, options)
  end
end
