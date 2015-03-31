class UpdateContactData < ActiveRecord::Migration
  def change
    Address.all.each do |a|
      c = a.contact
      c.city = a.city
      c.street = ""
      c.street << a.street         if a.street.present?
      c.street << "\n#{a.street2}" if a.street2.present?
      c.street << "\n#{a.street3}" if a.street3.present?
      c.zip = a.zip
      c.country_code = a.country_code
      c.state = a.state
      puts "#{c.id} changes: #{c.changes.inspect}; #{c.save(validate: false)}"
    end
  end
end
