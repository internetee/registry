class ActionView::Helpers::FormBuilder
  alias :orig_label :label

  # add a 'required' CSS class to the field label if the field is required
  def label(method, content_or_options = nil, options = nil, &block)
    if content_or_options && content_or_options.class == Hash
      options = content_or_options
    else
      content = content_or_options
    end

    if object.class.respond_to?(:validators_on) &&
      object.class.validators_on(method).map(&:class).include?(ActiveRecord::Validations::PresenceValidator)

      if options.class != Hash
        options = {:class => "required"}
      else
        options[:class] = ((options[:class] || "") + " required").split(" ").uniq.join(" ")
      end
    end

    self.orig_label(method, content, options || {}, &block)
  end
end
