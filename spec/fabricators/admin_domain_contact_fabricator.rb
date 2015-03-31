Fabricator(:admin_domain_contact) do
  contact { Fabricate(:contact) }
  after_build do |x|
    x.contact_code_cache = x.contact.code
  end
end
