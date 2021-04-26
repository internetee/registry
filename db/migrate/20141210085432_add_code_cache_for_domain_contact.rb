class AddCodeCacheForDomainContact < ActiveRecord::Migration[6.0]
  def change
    add_column :domain_contacts, :contact_code_cache, :string

    DomainContact.all.each do |x|
      x.contact_code_cache = x.contact.code
      x.save
    end
  end
end
