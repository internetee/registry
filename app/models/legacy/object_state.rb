module Legacy
  class ObjectState < Db
    self.table_name = :object_state
    attr_accessor :history_domain

    scope :valid, -> { where('valid_to IS NULL') }

    # legacy values. Just for log
    # 2 => "serverRenewProhibited",
    # 5 => "serverOutzoneManual",
    # 6 => "serverInzoneManual",
    # 7 => "serverBlocked",
    # 8 => "expirationWarning",
    # 9 => "expired",
    # 10 => "unguarded",
    # 11 => "validationWarning1",
    # 12 => "validationWarning2",
    # 13 => "notValidated",
    # 14 => "nssetMissing",
    # 15 => "outzone",
    # 18 => "serverRegistrantChangeProhibited",
    # 19 => "deleteWarning",
    # 20 => "outzoneUnguarded",
    # 1 => "serverDeleteProhibited",
    # 3 => "serverTransferProhibited",
    # 4 => "serverUpdateProhibited",
    # 16 => "linked",
    # 17 => "deleteCandidate",
    # 21 => "forceDelete"

    # new values
    STATE_NAMES = {
        2 => "serverRenewProhibited",
        5 => "serverHold",
        6 => "serverManualInzone",
        # 7 => "serverBlocked",
        9 => "expired",
        # 11 => "validationWarning1",
        # 13 => "notValidated",
        14 => "inactive",
        15 => "serverHold",
        18 => "serverRegistrantChangeProhibited",
        1 => "serverDeleteProhibited",
        3 => "serverTransferProhibited",
        4 => "serverUpdateProhibited",
        16 => "linked",
        17 => "deleteCandidate", # grupistaatus
        21 => "serverForceDelete" # grupistaatus
    }.freeze


    def name
      STATE_NAMES[state_id]
    end

    def desc
      map = {
        1 => "Delete prohibited",
        2 => "Registration renew prohibited",
        3 => "Sponsoring registrar change prohibited",
        4 => "Update prohibited",
        7 => "Domain blocked",
        8 => "Expires within 30 days",
        9 => "Expired",
        10 => "Domain is 30 days after expiration",
        11 => "Validation of domain expire in 30 days",
        12 => "Validation of domain expire in 15 days",
        13 => "Domain not validated",
        14 => "Domain has not associated nsset",
        15 => "Domain is not generated into zone",
        16 => "Has relation to other records in registry",
        17 => "Object is going to be deleted",
        18 => "Registrant change prohibited",
        19 => "Domain will be deleted in 11 days",
        20 => "Domain is out of zone after 30 days from expiration",
        21 => "Domain is forced to delete",
        5 => "Domain is administratively kept out of zone",
        6 => "Domain is administratively kept in zone"
      }

      map[state_id]
    end

    def get_current_domain_object(time, param)
      d_his = Legacy::DomainHistory.get_record_at(object_id, historyid)
      @history_domain = d_his

      hash  = d_his.get_current_domain_object(time, param)
      hash[:statuses] = Legacy::ObjectState.states_for_domain_at(object_id, time + 1)

      hash
    end

    def get_current_contact_object(time, param)
      d_his = Legacy::ContactHistory.get_record_at(object_id, historyid)
      hash  = d_his.get_current_contact_object(time, param)
      hash[:statuses] = Legacy::ObjectState.states_for_contact_at(object_id, time + 1)

      hash
    end

    class << self
       def changes_dates_for domain_id
         sql = %Q{SELECT distinct t_2.id, state.id state_dot_id, state.*,
                    extract(epoch from valid_from) valid_from_unix, extract(epoch from valid_to) valid_to_unix
                    FROM object_history t_2
                      JOIN object_state state ON (t_2.historyid >= state.ohid_from
                                                  AND (t_2.historyid <= state.ohid_to OR state.ohid_to IS NULL))
                                                 AND t_2.id = state.object_id
                    WHERE state.object_id=#{domain_id};}
         hash = {}
         find_by_sql(sql).each do |rec|
           hash[rec.valid_from.try(:to_time)] = [{id: rec.state_dot_id, klass: self, param: :valid_from}] if rec.valid_from
           hash[rec.valid_to.try(:to_time)]   = [{id: rec.state_dot_id, klass: self, param: :valid_to}]   if rec.valid_to
         end
         hash
       end

      def get_record_at domain_id, rec_id
        sql = %Q{SELECT distinct t_2.historyid, state.*
                    FROM object_history t_2
                      JOIN object_state state ON (t_2.historyid >= state.ohid_from
                                                  AND (t_2.historyid <= state.ohid_to OR state.ohid_to IS NULL))
                                                 AND t_2.id = state.object_id
                    WHERE state.object_id=#{domain_id} AND  state.id = #{rec_id};}
        find_by_sql(sql).first
      end

      def states_for_domain_at(domain_id, time)
        sql = %Q{SELECT state.*
          FROM object_history t_2
            JOIN object_state state ON (t_2.historyid >= state.ohid_from
                                        AND (t_2.historyid <= state.ohid_to OR state.ohid_to IS NULL))
                                       AND t_2.id = state.object_id
          WHERE state.object_id=#{domain_id}
            AND (valid_from is null or valid_from <= '#{time.to_s}'::TIMESTAMPTZ)
            AND (valid_to is null or valid_to >= '#{time}'::TIMESTAMPTZ)
          }
        arr = find_by_sql(sql).uniq
        arr.map!(&:name) if arr.any?
        arr.present? ? arr : [::DomainStatus::OK]
      end


      def states_for_contact_at(contact_id, time)
        sql = %Q{SELECT state.*
          FROM object_history t_2
            JOIN object_state state ON (t_2.historyid >= state.ohid_from
                                        AND (t_2.historyid <= state.ohid_to OR state.ohid_to IS NULL))
                                       AND t_2.id = state.object_id
          WHERE state.object_id=#{contact_id}
            AND (valid_from is null or valid_from <= '#{time.to_s}'::TIMESTAMPTZ)
            AND (valid_to is null or valid_to >= '#{time}'::TIMESTAMPTZ)
          }

        (find_by_sql(sql).uniq.to_a.map(&:name) + [::Contact::OK]).compact.uniq
      end
    end
  end
end
