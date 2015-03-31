class UpdateDomainContactData < ActiveRecord::Migration
  def change
    DomainContact.all.each do |dc|
      case dc.contact_type
      when 'admin'
        dc.type = 'AdminDomainContact'
      when 'tech'
        dc.type = 'TechDomainContact'
      end
      if dc.changes.present?
        puts "Changed: #{dc.id}: #{dc.changes.inspect} #{dc.save}"
      else
        puts "No changes: #{dc.id}"
      end
    end
  end
end
