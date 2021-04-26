class DataUpdateRegisntrarCodes < ActiveRecord::Migration[6.0]
  def change
    puts 'Registrar code updates:'
    Registrar.all.each do |r|
      next if r.code.present?
      r[:code] = r.name.parameterize
      puts "#{r.id}: #{r.changes.inspect}"
      r.save(validate: false)
    end
  end
end
