module FormHelper
  def legal_document_field(object_name, method, options = {})
    options[:data] = { legal_document: true }
    options[:accept] = legal_document_types unless options[:accept]

    file_field(object_name, method, options)
  end

  def money_field(object_name, method, options = {})
    options[:pattern] = '^[0-9.,]+$' unless options[:pattern]
    options[:maxlength] = 255 unless options[:maxlength]

    text_field(object_name, method, options)
  end

  def language_select(object, method, choices = nil, options = {}, html_options = {}, &block)
    choices = options_for_select({ en: 'English', et: 'Estonian' }.invert, options[:selected])
    select(object, method, choices, options, html_options, &block)
  end
end
