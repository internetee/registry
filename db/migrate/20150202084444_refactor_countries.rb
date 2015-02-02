class RefactorCountries < ActiveRecord::Migration
  def change
    add_column :registrars, :country_code, :string
    add_column :users, :country_code, :string
    add_column :addresses, :country_code, :string

    Registrar.all.each do |x|
      x.country_code = x.country_deprecated.try(:iso)
      x.save(validate: false)
    end

    User.all.each do |x|
      x.country_code = x.country_deprecated.try(:iso)
      x.save(validate: false)
    end

    Address.all.each do |x|
      x.country_code = x.country_deprecated.try(:iso)
      x.save(validate: false)
    end
  end
end
