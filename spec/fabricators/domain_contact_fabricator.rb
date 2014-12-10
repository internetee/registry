Fabricator(:domain_contact) do
  contact { Fabricate(:contact) }
  contact_type 'admin'
  after_build do |x|
    x.contact_code_cache = x.contact.code
  end
end
