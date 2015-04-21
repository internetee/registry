class ActionView::Helpers::FormBuilder
  alias_method :orig_label, :label

  # add a 'required' CSS class to the field label if the field is required
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def label(method, content_or_options = nil, options = nil, &block)
    if content_or_options && content_or_options.class == Hash
      options = content_or_options
    else
      content = content_or_options
    end

    if object.class.respond_to?(:validators_on) &&
      object.class.validators_on(method).map(&:class).include?(ActiveRecord::Validations::PresenceValidator)

      if options.class != Hash
        options = { class: 'required' }
      else
        options[:class] = ((options[:class] || "") + ' required').split(' ').uniq.join(' ')
      end
    end

    orig_label(method, content, options || {}, &block)
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
end
