class AddRpd9FieldsToRdapPrivilegeGrants < ActiveRecord::Migration[6.1]
  # RPD §9 recommended fields missing on rdap_privilege_grants today:
  #   full_name        - required, admin display + audit
  #   legal_basis_ref  - required, legal basis / agreement reference
  #   personal_id_code - optional, sensitive PII; capture-only (never listed,
  #                      never logged, never in the internal grants serializer)
  #
  # full_name / legal_basis_ref are NOT NULL. The table is new (created in this
  # same integration branch) so it may already carry a few rows; a temporary
  # empty-string default lets the NOT NULL constraint be applied without a data
  # migration, then the default is dropped so new rows must supply a value
  # (enforced at the model layer by presence: true).
  def up
    add_column :rdap_privilege_grants, :full_name, :string, null: false, default: ''
    add_column :rdap_privilege_grants, :legal_basis_ref, :string, null: false, default: ''
    add_column :rdap_privilege_grants, :personal_id_code, :string

    change_column_default :rdap_privilege_grants, :full_name, from: '', to: nil
    change_column_default :rdap_privilege_grants, :legal_basis_ref, from: '', to: nil
  end

  def down
    remove_column :rdap_privilege_grants, :personal_id_code
    remove_column :rdap_privilege_grants, :legal_basis_ref
    remove_column :rdap_privilege_grants, :full_name
  end
end
