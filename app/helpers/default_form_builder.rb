class DefaultFormBuilder < ActionView::Helpers::FormBuilder
  def legal_document_field(method, options = {})
    self.multipart = true
    @template.legal_document_field(@object_name, method, objectify_options(options))
  end
end
