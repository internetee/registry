module BusinessRegistry
  class DomainNameGeneratorService
    LEGAL_FORMS = %w[AS OU FIE OÜ MTÜ].freeze
    
    def self.generate(name)
      base_name = sanitize_input(name)
      legal_form = extract_legal_form(base_name)
      base_variants = generate_variants(base_name.sub(/\s+#{legal_form}\s*$/i, ''))
      base_variants + generate_variants_with_legal_form(base_name, legal_form)
    end
    
    private
    
    def self.sanitize_input(name)
      name.gsub(/[^[:alnum:]\s\-]/, '').strip
    end
    
    def self.extract_legal_form(name)
      words = name.split
      LEGAL_FORMS.find { |form| words.last.upcase == form }
    end
    
    def self.generate_variants(name)
      [
        name.downcase.gsub(/\s+/, ''),
        name.downcase.gsub(/\s+/, '-'),
        name.downcase.gsub(/\s+/, '_')
      ]
    end
    
    def self.generate_variants_with_legal_form(name, legal_form)
      return [] unless legal_form
      
      base_name = name.sub(/\s+#{legal_form}\s*$/i, '').downcase
      base_variants = generate_variants(base_name)
      
      legal_form_variants = [
        legal_form.downcase,
        legal_form.downcase.tr('ü', 'u'),
        "-#{legal_form.downcase}",
        "-#{legal_form.downcase.tr('ü', 'u')}",
        "_#{legal_form.downcase}",
        "_#{legal_form.downcase.tr('ü', 'u')}"
      ]
      
      base_variants.product(legal_form_variants).map(&:join)
    end
  end
end