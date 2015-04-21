module DisableHtml5Validation
  extend ActiveSupport::Concern

  class_methods do
    def auto_html5_validation
      false
    end
  end
end
