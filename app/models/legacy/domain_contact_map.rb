module Legacy
  class DomainContactMap < Db
    self.table_name = :domain_contact_map

    # belongs_to :contact, foreign_key: :contactid, primary_key: :legacy_id, class_name: '::Contact'
  end
end
