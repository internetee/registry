module BusinessRegistry
  class DomainNameGeneratorService
    LEGAL_FORMS = %w[AS OU FIE OÜ MTÜ].freeze
 
    def self.generate(name)
      base_name = sanitize_input(name)
      base_name = remove_legal_form(base_name)
      variants = [
        base_name.downcase.gsub(/\s+/, ''),
        base_name.downcase.gsub(/\s+/, '-')
      ]
      
      zone_origins = DNS::Zone.pluck(:origin).uniq
      
      domain_names = variants.product(zone_origins).map { |variant, origin| "#{variant}.#{origin}" }
      
      domain_names.uniq
    end
    
    private
    
    def self.sanitize_input(name)
      name.gsub(/[^[:alnum:]\s\-]/, '').strip
    end

    def self.remove_legal_form(name)
      LEGAL_FORMS.each do |form|
        name = name.gsub(/\s+#{form}\s*$/i, '')
      end
      name
    end

  end
end