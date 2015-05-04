class ValidateRegistrarCodes < ActiveRecord::Migration
  def change
    Registrar.all.each do |registrar|
      if registrar.code.present?
        registrar.update_column(:code, registrar.code.gsub(/[ :]/, '').upcase)
      else
        puts "NB! FOUND REGISTRAR WITHOUT CODE (HANDLER): #{registrar.id}; #{registrar.name}"
        puts "Please add registrar code manually in database!"
      end
    end
  end
end
