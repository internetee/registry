class DataUpdateRegisntrarCodes < ActiveRecord::Migration
  def change
    puts 'Registrar code updates:'
    Registrar.all.each do |r|
      next if r.code.present?
      r[:code] = r.name.parameterize
      puts "#{r.id}: #{r.changes.inspect}"
      r.save!
    end
  end
end
