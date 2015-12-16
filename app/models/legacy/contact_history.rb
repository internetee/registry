module Legacy
  class ContactHistory < Db
    self.table_name = :contact_history
    self.primary_key = :id

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
    belongs_to :contact, foreign_key: :id
    belongs_to :history, foreign_key: :historyid
    has_one :object_history, foreign_key: :historyid, primary_key: :historyid

    def get_current_contact_object(time, change_param)
      x = self
      if 4 == x.ssntype
        name = x.organization.try(:strip).presence || x.name.try(:strip).presence
      else
        name = x.name.try(:strip).presence || x.organization.try(:strip).presence
      end

      {
        code: x.object_registry.name.try(:strip),
        phone: x.telephone.try(:strip),
        email: [x.email.try(:strip), x.notifyemail.try(:strip)].uniq.select(&:present?).join(', '),
        fax: x.fax.try(:strip),
        created_at: x.object_registry.try(:crdate),
        updated_at: x.object_history.read_attribute(:update).nil? ? x.object_registry.try(:crdate) : x.object_history.read_attribute(:update),
        ident: x.ssn.try(:strip),
        ident_type: ::Legacy::Contact::IDENT_TYPE_MAP[x.ssntype],
        auth_info: x.object_history.authinfopw.try(:strip),
        name: name,
        registrar_id: ::Registrar.find_by(legacy_id: x.object_history.try(:clid)).try(:id),
        creator_str: x.object_registry.try(:registrar).try(:name),
        updator_str: x.object_history.try(:registrar).try(:name) ? x.object_history.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
        legacy_id: x.id,
        street: [x.street1.try(:strip), x.street2.try(:strip), x.street3.try(:strip)].compact.join(", "),
        city: x.city.try(:strip),
        zip: x.postalcode.try(:strip),
        state: x.stateorprovince.try(:strip),
        country_code: x.country.try(:strip),
        statuses: ::Legacy::ObjectState.states_for_contact_at(x.id, time)
      }
    end

    class << self
      def changes_dates_for domain_id
        sql = %Q{SELECT  dh.*, valid_from
              FROM contact_history dh JOIN history h ON dh.historyid=h.id where dh.id=#{domain_id};}
        # find_by_sql(sql).map{|e| e.attributes.values_at("valid_from") }.flatten.each_with_object({}){|e,h|h[e.try(:to_f)] = [self]}

        hash = {}
        find_by_sql(sql).each do |rec|
          hash[rec.valid_from.try(:to_time)] = [{id: rec.historyid, klass: self, param: :valid_from}] if rec.valid_from
        end
        hash
      end

      def get_record_at domain_id, rec_id
        sql = %Q{SELECT  dh.*, h.valid_from, h.valid_to
            from contact_history dh JOIN history h ON dh.historyid=h.id
            where dh.id=#{domain_id} and dh.historyid = #{rec_id} ;}
        find_by_sql(sql).first
      end

    end
  end
end
