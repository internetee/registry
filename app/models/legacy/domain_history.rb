module Legacy
  class DomainHistory < Db
    self.table_name = :domain_history
    self.primary_key = :id

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
    belongs_to :domain, foreign_key: :id
    belongs_to :history, foreign_key: :historyid
    has_one :object_history, foreign_key: :historyid, primary_key: :historyid
    has_many :nsset_histories,  foreign_key: :id, primary_key: :nsset
    has_many :domain_contact_map_histories, foreign_key: :historyid, primary_key: :historyid
    has_many :nsset_contact_map_histories,  foreign_key: :historyid, primary_key: :historyid

    def get_current_domain_object(time, change_param)
      x = self
      {
          name:          SimpleIDN.to_unicode(x.object_registry.name.try(:strip)),
          registrar_id:  ::Registrar.find_by(legacy_id: x.object_history.try(:clid)).try(:id),
          registrant_id: new_registrant_id,
          registered_at: x.object_registry.try(:crdate),
          valid_from:    x.object_registry.try(:crdate),
          valid_to:      x.exdate,
          auth_info:     x.object_history.authinfopw.try(:strip),
          created_at:    x.object_registry.try(:crdate),
          updated_at:    x.object_history.read_attribute(:update).nil? ? x.object_registry.try(:crdate) : x.object_history.read_attribute(:update),
          name_dirty:    x.object_registry.name.try(:strip),
          name_puny:     SimpleIDN.to_ascii(x.object_registry.name.try(:strip)),
          period:        1,
          period_unit:   'y',
          creator_str:   x.object_registry.try(:registrar).try(:name),
          updator_str:   x.object_history.try(:registrar).try(:name) ? x.object_history.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
          legacy_id:     x.id,
          legacy_registrar_id:  x.object_history.try(:clid),
          legacy_registrant_id: x.registrant,
          statuses:      Legacy::ObjectState.states_for_domain_at(x.id, time)
      }
    end

    def get_admin_contact_new_ids
      c_ids = domain_contact_map_histories.pluck(:contactid).join("','")
      DomainVersion.where("object->>'legacy_id' IN ('#{c_ids}')").uniq.pluck(:item_id)
    end
    def get_tech_contact_new_ids
      c_ids = nsset_contact_map_histories.pluck(:contactid).join("','")
      DomainVersion.where("object->>'legacy_id' IN ('#{c_ids}')").uniq.pluck(:item_id)
    end

    def new_registrant_id
      @new_registrant_id ||= ::Contact.find_by(legacy_id: registrant).try(:id)
    end

    def user
      @user ||= Registrar.find_by(legacy_id: obj_his.upid || obj_his.clid).try(:api_users).try(:first)
    end


    # returns imported nameserver ids
    def import_nameservers_history(new_domain, time)
      #removing previous nameservers
      NameserverVersion.where("object->>legacy_domain_id").where(event: :create).where("created_at <= ?", time).each do |nv|
        if NameserverVersion.where(item_type: nv.item_type, item_id: nv.item_id, event: :destroy).none?
          NameserverVersion.create!(
              item_type: nv.item_type,
              item_id:   nv.item_id,
              event:     :destroy,
              whodunnit: user.try(:id),
              object:    nv.object_changes.each_with_object({}){|(k,v),hash| hash[k] = v.last },
              object_changes: {},
              created_at: time
          )
        end
      end


      if (nssets = nsset_histories.at(time).to_a).any?
        ids = []
        nssets.each do |nsset|
          nsset.host_histories.at(time).each do |host|
            ips = {ipv4: [],ipv6: []}
            host.host_ipaddr_map_histories.at(time).each do |ip_map|
              next unless ip_map.ipaddr
              ips[:ipv4] << ip_map.ipaddr.to_s.strip if ip_map.ipaddr.ipv4?
              ips[:ipv6] << ip_map.ipaddr.to_s.strip if ip_map.ipaddr.ipv6?
            end

            server = {
                id: Nameserver.next_id,
                hostname: host.fqdn.try(:strip),
                ipv4: ips[:ipv4],
                ipv6: ips[:ipv6],
                creator_str: object_registry.try(:registrar).try(:name),
                updator_str: object_history.try(:registrar).try(:name) || object_registry.try(:registrar).try(:name),
                legacy_domain_id:  id,
                domain_id: new_domain.id,
                created_at: nsset.object_registry.try(:crdate),
                updated_at: nsset.object_registry.try(:object_history).read_attribute(:update) || nsset.object_registry.try(:crdate)
            }

            NameserverVersion.create!(
                item_type: Nameserver.to_s,
                item_id:   server[:id],
                event:     :create,
                whodunnit: user.try(:id),
                object:    nil,
                object_changes: server.each_with_object({}){|(k,v), h| h[k] = [nil, v]},
                created_at: time
            )
            ids << server[:id]
          end

        end
        ids
      else
        []
      end
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


      # def last_history_action domain_id
      #   sql = %Q{SELECT  dh.*, h.valid_from, h.valid_to
      #       from domain_history dh JOIN history h ON dh.historyid=h.id
      #       where dh.id=#{domain_id} order by dh.historyid desc limit 1;}
      #   find_by_sql(sql).first
      # end
    end
  end
end
