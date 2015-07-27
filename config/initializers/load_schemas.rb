EPP_SCHEMA = Nokogiri::XML::Schema(File.read("lib/schemas/epp-1.0.xsd"))
DOMAIN_SCHEMA = Nokogiri::XML::Schema(File.read("lib/schemas/domain-eis-1.0.xsd"))
CONTACT_SCHEMA = Nokogiri::XML::Schema(File.read("lib/schemas/contact-eis-1.0.xsd"))
