class AddPolymorphicRelationToEmailAddressVerification < ActiveRecord::Migration[6.1]
  def change
    remove_column :email_address_verifications, :email, :string
    remove_column :email_address_verifications, :success, :boolean
    remove_column :email_address_verifications, :domain, :string

    change_table 'email_address_verifications' do |t|
      t.references :email_verifable, polymorphic: true
      t.jsonb :result
      t.integer :times_scanned
    end

    reversible do |change|
      change.up do
        EmailAddressVerification.destroy_all

        execute <<-SQL
          CREATE TYPE email_verification_type AS ENUM ('regex', 'mx', 'smtp');
        SQL

        add_column :email_address_verifications, :type, :email_verification_type
      end

      change.down do
        execute <<-SQL
          DROP TYPE email_verification_type;
        SQL
      end
    end
  end
end
