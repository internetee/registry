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

    scope :by_date, lambda { |date_range|
      where(recorded_at: date_range)
    }

    def self.contact_ids
      pluck(Arel.sql("new_value->'contact_id'"), Arel.sql("old_value->'contact_id'")).flatten.reject(&:blank?)
    end

    def contact_id
      case action
      when 'DELETE'
        old_value['contact_id']
      else
        new_value['contact_id']
      end
    end

    def contact_code
      case action
      when 'DELETE'
        old_value['contact_code_cache']
      when 'UPDATE'
        prev_contact_code = Contact.find_by(id: old_value['contact_id'])&.code
        new_contact_code = Contact.find_by(id: new_value['contact_id'])&.code

        old_code = prev_contact_code || old_value['contact_code_cache']
        new_code = new_contact_code || new_value['contact_code_cache']

        "#{old_code} >> #{new_code}"
      else
        new_value['contact_code_cache']
      end
    end
  end
end
