module BusinessRegistry
  class DomainNameGeneratorService
    LEGAL_FORMS = %w[AS OU FIE OÜ].freeze
    
    def self.generate(name)
      base_name = remove_legal_forms(sanitize_input(name))
      variants = generate_variants(base_name)
      variants + generate_additional_variants(variants)
    end
    
    private
    
    def self.sanitize_input(name)
      name.gsub(/[^[:alnum:]\s\-]/, '').strip
    end
    
    def self.remove_legal_forms(name)
      words = name.split
      words.reject { |word| LEGAL_FORMS.include?(word.upcase) }.join(' ').strip
    end
    
    def self.generate_variants(name)
      [
        name.downcase.gsub(/\s+/, ''),
        name.downcase.gsub(/\s+/, '-'),
        name.downcase.gsub(/\s+/, '_')
      ]
    end
    
    def self.generate_additional_variants(variants)
      current_year = Time.current.year
      variants.map { |v| "#{v}#{current_year}" }
    end
  end
end
