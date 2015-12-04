module Legacy
  class DomainHistory < Db
    self.table_name = :domain_history
    self.primary_key = :id

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
    belongs_to :domain, foreign_key: :id
    belongs_to :history, foreign_key: :historyid
    has_one :object_history, foreign_key: :historyid, primary_key: :historyid

    def get_current_domain_object(change_param)
      x = self
      {
          name:          SimpleIDN.to_unicode(x.object_registry.name.try(:strip)),
          registrar_id:  Registrar.find_by(legacy_id: x.object.try(:clid)).try(:id),
          registered_at: x.object_registry.try(:crdate),
          valid_from:    x.object_registry.try(:crdate),
          valid_to:      x.exdate,
          auth_info:     x.object.authinfopw.try(:strip),
          created_at:    x.object_registry.try(:crdate),
          updated_at:    x.object.read_attribute(:update).nil? ? x.object_registry.try(:crdate) : x.object.read_attribute(:update),
          name_dirty:    x.object_registry.name.try(:strip),
          name_puny:     SimpleIDN.to_ascii(x.object_registry.name.try(:strip)),
          period:        1,
          period_unit:   'y',
          creator_str:   x.object_registry.try(:registrar).try(:name),
          updator_str:   x.object.try(:registrar).try(:name) ? x.object.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
          legacy_id:     x.id,
          legacy_registrar_id:  x.object_registry.try(:crid),
          legacy_registrant_id: x.registrant,
          statuses:             x.states
      }
    end

    def get_current_changes(param)
      p "not implemented #{__method__}"
    end

    class << self
      def changes_dates_for domain_id
        sql = %Q{SELECT  dh.*, valid_from
              FROM domain_history dh JOIN history h ON dh.historyid=h.id where dh.id=#{domain_id};}
        # find_by_sql(sql).map{|e| e.attributes.values_at("valid_from") }.flatten.each_with_object({}){|e,h|h[e.try(:to_f)] = [self]}

        hash = {}
        find_by_sql(sql).each do |rec|
          hash[rec.valid_from.try(:to_time)] = [{id: rec.historyid, klass: self, param: :valid_from}] if rec.valid_from
        end
        hash
      end

      def get_record_at domain_id, rec_id
        sql = %Q{SELECT  dh.*, h.valid_from, h.valid_to
            from domain_history dh JOIN history h ON dh.historyid=h.id
            where dh.id=#{domain_id} and dh.historyid = #{rec_id} ;}
        find_by_sql(sql).first
      end
    end
  end
end
