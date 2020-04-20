module Audit
  class DomainContactHistory < BaseHistory
    self.table_name = 'audit.domain_contacts'

    scope :by_domain, lambda { |domain_id|
      where("new_value ->> 'domain_id' = ':x' OR old_value ->> 'domain_id' = ':x'", x: domain_id)
    }

    scope :admin, lambda {
      where("new_value ->> 'type' = :x OR old_value ->> 'type' = :x", x: 'AdminDomainContact')
    }

    scope :tech, lambda {
      where("new_value ->> 'type' = :x OR old_value ->> 'type' = :x", x: 'TechDomainContact')
    }

    def self.contact_ids
      pluck(Arel.sql("new_value->'contact_id'"))
    end
  end
end
