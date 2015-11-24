module Legacy
  class DomainHistory < Db
    self.table_name = :domain_history

    belongs_to :domain, foreign_key: :id
    belongs_to :history, foreign_key: :historyid
    has_one :object_history, foreign_key: :historyid, primary_key: :historyid

    def get_current_domain_object(param)
      p "not implemented #{__method__}"
    end

    def get_current_changes(param)
      p "not implemented #{__method__}"
    end

    class << self
      def changes_dates_for domain_id
        sql = %Q{SELECT  dh.*, valid_from--, extract(epoch from h.valid_from) valid_from_unix, extract(epoch from h.valid_to) valid_to_unix
              FROM domain_history dh JOIN history h ON dh.historyid=h.id where dh.id=#{domain_id};}
        # find_by_sql(sql).map{|e| e.attributes.values_at("valid_from") }.flatten.each_with_object({}){|e,h|h[e.try(:to_f)] = [self]}

        hash = {}
        find_by_sql(sql).each do |rec|
          hash[rec.valid_from.try(:to_time)] = [{id: rec.historyid, klass: self, param: :valid_from}] if rec.valid_from
        end
        hash
      end

      def get_record_at domain_id, rec_id
        sql = %Q{SELECT  dh.*, h.valid_from, h.valid_to from domain_history dh JOIN history h ON dh.historyid=h.id
            where dh.id=#{domain_id} and dh.historyid = #{rec_id} ;}
        find_by_sql(sql).first
      end
    end
  end
end
