class DefaultFormBuilder < ActionView::Helpers::FormBuilder
  def legal_document_field(method, options = {})
    self.multipart = true
    @template.legal_document_field(@object_name, method, objectify_options(options))
  end

  def money_field(method, options = {})
    @template.money_field(@object_name, method, objectify_options(options))
  end

  def language_select(method, choices = nil, options = {}, html_options = {}, &block)
    options[:selected] = @object.send(method) unless options[:selected]
    @template.language_select(@object_name, method, choices, objectify_options(options),
                              @default_options.merge(html_options),
                              &block)
  end
end
