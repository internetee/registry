class AddRegistrarsUniqueConstraints < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE registrars ADD CONSTRAINT unique_name UNIQUE (name);
      ALTER TABLE registrars ADD CONSTRAINT unique_reg_no UNIQUE (reg_no);
      ALTER TABLE registrars ADD CONSTRAINT unique_reference_no UNIQUE (reference_no);
      ALTER TABLE registrars ADD CONSTRAINT unique_code UNIQUE (code);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE registrars DROP CONSTRAINT unique_name;
      ALTER TABLE registrars DROP CONSTRAINT unique_reg_no;
      ALTER TABLE registrars DROP CONSTRAINT unique_reference_no;
      ALTER TABLE registrars DROP CONSTRAINT unique_code;
    SQL
  end
end
