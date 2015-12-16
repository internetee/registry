module Legacy
  class DnskeyHistory < Db
    self.table_name = :dnskey_history

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
    has_one :object_history, foreign_key: :historyid, primary_key: :historyid


    def self.for_at(keysetid, time)
      return [] unless keysetid

      sql = %Q{select distinct dh.id, dh.keysetid, dh.flags, dh.protocol, dh.alg, dh.key,
                  first_value(history.valid_from) OVER (PARTITION BY key ORDER BY history.valid_from ASC NULLS FIRST) valid_from,
                  first_value(history.valid_to) OVER (PARTITION BY key ORDER BY history.valid_to DESC NULLS FIRST) valid_to
                FROM dnskey_history dh JOIN history ON dh.historyid=history.id
                WHERE dh.keysetid IN (#{keysetid})
                AND (valid_from is null or valid_from <= '#{time.to_s}'::TIMESTAMPTZ)
                AND (valid_to is null or valid_to >= '#{time}'::TIMESTAMPTZ)
                ORDER BY dh.id;}
      find_by_sql(sql)
    end

    def new_object_hash(old_domain, new_domain)
      new_object_mains(new_domain).merge(
          creator_str: old_domain.object_registry.try(:registrar).try(:name),
          updator_str: old_domain.object_history.try(:registrar).try(:name) || old_domain.object_registry.try(:registrar).try(:name),
          legacy_domain_id: old_domain.id,
          legacy_keyset_id: keysetid,
          updated_at: (!object_registry.try(:object_history) || object_registry.try(:object_history).read_attribute(:update).nil?) ? (try(:crdate)||Time.zone.now) : object_registry.try(:object_history).read_attribute(:update)
      )
    end

    def new_object_mains(new_domain)
      @new_object_mains ||= {
       domain_id:  new_domain.id,
       flags:      flags,
       protocol:   protocol,
       alg:        alg,
       public_key: key
      }
    end

    def historical_data(old_domain, new_domain, time_attr = :valid_from)
      {
          whodunnit: old_domain.user.try(:id),
          object: nil,
          object_changes: new_object_hash(old_domain, new_domain).each_with_object({}){|(k,v), h| h[k] = [nil, v]},
          created_at: [try(time_attr), old_domain.try(time_attr)].max
      }
    end
  end
end
