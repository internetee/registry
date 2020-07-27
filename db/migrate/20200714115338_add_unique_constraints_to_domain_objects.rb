class AddUniqueConstraintsToDomainObjects < ActiveRecord::Migration[6.0]
  def up

    execute <<-SQL
      alter table domain_contacts
        drop constraint if exists uniq_contact_of_type_per_domain;
    SQL

    execute <<-SQL
      alter table nameservers
        drop constraint if exists uniq_hostname_per_domain;
    SQL

    execute <<-SQL
      alter table domain_contacts
        add constraint uniq_contact_of_type_per_domain unique (domain_id, type, contact_id);
    SQL

    execute <<-SQL
      alter table nameservers
        add constraint uniq_hostname_per_domain unique (domain_id, hostname);
    SQL
  end

  def down
    execute <<-SQL
      alter table domain_contacts
        drop constraint if exists uniq_contact_of_type_per_domain;
    SQL

    execute <<-SQL
      alter table nameservers
        drop constraint if exists uniq_hostname_per_domain;
    SQL
  end
end
