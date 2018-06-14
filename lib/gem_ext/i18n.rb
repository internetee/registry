# Don't raise error when nil
# http://stackoverflow.com/questions/9467034/rails-i18n-how-to-handle-case-of-a-nil-date-being-passed-ie-lnil
module I18n
  class << self
    alias_method :original_localize, :localize

    def localize(object, options = {})
      object.present? ? original_localize(object, options) : ''
    end
  end
end
