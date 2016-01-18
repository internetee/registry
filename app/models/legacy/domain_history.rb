module Legacy
  class DomainHistory < Db
    self.table_name = :domain_history
    self.primary_key = :id
    class_attribute :dnssecs
    class_attribute :namesrvs

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
          registrar_id:  ::Legacy::Domain.new_registrar_cached(x.object_history.try(:clid)).try(:id),
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
      @user ||= begin
        obj_his = Legacy::ObjectHistory.find_by(historyid: historyid)
        Legacy::Domain.new_api_user_cached(obj_his.upid || obj_his.clid)
      end
    end

    def history_domain
      self
    end


    # returns imported nameserver ids
    def import_nameservers_history(new_domain, time)
      self.class.namesrvs ||= {}
      self.class.namesrvs[id] ||= {}
      ids = []

      nsset_histories.at(time).to_a.each do |nsset|
        nsset.host_histories.at(time).each do |host|
          ips = {ipv4: [],ipv6: []}
          host.host_ipaddr_map_histories.where.not(ipaddr: nil).at(time).each do |ip_map|
            ips[:ipv4] << ip_map.ipaddr.to_s.strip if ip_map.ipaddr.ipv4?
            ips[:ipv6] << ip_map.ipaddr.to_s.strip if ip_map.ipaddr.ipv6?
          end

          main_attrs = {
              hostname: SimpleIDN.to_unicode(host.fqdn.try(:strip)),
              ipv4: ips[:ipv4].sort,
              ipv6: ips[:ipv6].sort,
              legacy_domain_id:  id,
              domain_id: new_domain.id,
          }
          server = main_attrs.merge(
              creator_str: object_registry.try(:registrar).try(:name),
              updator_str: object_history.try(:registrar).try(:name) || object_registry.try(:registrar).try(:name),
              created_at: nsset.object_registry.try(:crdate),
              updated_at: nsset.object_registry.try(:object_history).read_attribute(:update) || nsset.object_registry.try(:crdate)
          )


          if val = self.class.namesrvs[id][main_attrs]
            ids << val
          else # if not found we should check current dnssec and historical if changes were done
            # firstly we need to select the first historical object to take the earliest from create or destroy
            if version = ::NameserverVersion.where("object->>'domain_id'='#{main_attrs[:domain_id]}'").
                where("object->>'legacy_domain_id'='#{main_attrs[:legacy_domain_id]}'").
                where("object->>'hostname'='#{main_attrs[:hostname]}'").
                reorder("created_at ASC").first
              server[:id] = version.item_id.to_i
              version.item.versions.where(event: :create).first_or_create!(
                  whodunnit: user.try(:id),
                  object: nil,
                  object_changes: server.each_with_object({}){|(k,v), h| h[k] = [nil, v]},
                  created_at: time
              )
              if !version.ipv4.sort.eql?(main_attrs[:ipv4]) || !version.ipv6.sort.eql?(main_attrs[:ipv6])
                object_changes = {}
                server.stringify_keys.each{|k, v| object_changes[k] = [v, version.object[k]] if v != version.object[k] }
                version.item.versions.where(event: :update).create!(
                    whodunnit: user.try(:id),
                    object: server,
                    object_changes: object_changes,
                    created_at: time
                )
              end

            # if no historical data - try to load existing
            elsif (list = ::Nameserver.where(domain_id: main_attrs[:domain_id], legacy_domain_id: main_attrs[:legacy_domain_id], hostname: main_attrs[:hostname]).to_a).any?
              if new_no_version = list.detect{|e|e.versions.where(event: :create).none?} # no create version, so was created via import
                server[:id] = new_no_version.id.to_i
                new_no_version.versions.where(event: :create).first_or_create!(
                    whodunnit: user.try(:id),
                    object: nil,
                    object_changes: server.each_with_object({}){|(k,v), h| h[k] = [nil, v]},
                    created_at: time
                )
                if !new_no_version.ipv4.sort.eql?(main_attrs[:ipv4]) || !new_no_version.ipv6.sort.eql?(main_attrs[:ipv6])
                  object_changes = {}
                  server.stringify_keys.each{|k, v| object_changes[k] = [v, new_no_version.attributes[k]] if v != new_no_version.attributes[k] }
                  new_no_version.versions.where(event: :update).create!(
                      whodunnit: user.try(:id),
                      object: server,
                      object_changes: object_changes,
                      created_at: time
                  )
                end
              else
                server[:id] = ::Nameserver.next_id
                create_nameserver_history(server,time)
              end

            else
              server[:id] = ::Nameserver.next_id
              create_nameserver_history(server,time)
            end
            self.class.namesrvs[id][main_attrs] = server[:id]
            ids << server[:id]

          end
        end

      end
      ids
    end

    def create_nameserver_history server, time
      ::NameserverVersion.where(item_id: server[:id], item_type: ::Nameserver.to_s).where(event: :create).first_or_create!(
          whodunnit: user.try(:id), object: nil, created_at: time,
          object_changes: server.each_with_object({}){|(k,v), h| h[k] = [nil, v]},
      )
      ::NameserverVersion.where(item_id: server[:id], item_type: ::Nameserver.to_s).where(event: :destroy).create!(
          whodunnit: user.try(:id), object: server, created_at: Time.now + 2.days,
          object_changes: {},
      )
    end

    # returns imported dnskey ids
    def import_dnskeys_history(new_domain, time)
      self.class.dnssecs ||= {}
      self.class.dnssecs[id] ||= {}
      ids = []
      Legacy::DnskeyHistory.for_at(keyset, time).each do |dns|
        # checking if we have create history for dnskey (cache)
        if val = self.class.dnssecs[id][dns]
          ids << val
        else # if not found we should check current dnssec and historical if changes were done
          # if current object wasn't changed
          if item=::Dnskey.where(dns.new_object_mains(new_domain)).first
            item.versions.where(event: :create).first_or_create!(dns.historical_data(self, new_domain))
            self.class.dnssecs[id][dns] = item.id
            ids << item.id
          # if current object was changed
          elsif (versions = ::DnskeyVersion.where("object->>'legacy_domain_id'='#{id}'").to_a).any?
            versions.each do |v|
              if v.object.slice(*dns.new_object_mains(new_domain).stringify_keys.keys) == dns.new_object_mains(new_domain).keys
                self.class.dnssecs[id][dns] = v.item_id
                ids << v.item_id
                v.item.versions.where(event: :create).first_or_create!(dns.historical_data(self, new_domain))
              end
            end
          # if no history was here
          else
            item=::Dnskey.new(id: ::Dnskey.next_id)
            DnskeyVersion.where(item_type: ::Dnskey.to_s, item_id: item.id).where(event: :create).first_or_create!(dns.historical_data(self, new_domain))
            DnskeyVersion.where(item_type: ::Dnskey.to_s, item_id: item.id).where(event: :destroy).first_or_create!(dns.historical_data(self, new_domain), :valid_to) if dns.valid_to
            self.class.dnssecs[id][dns] = item.id
            ids << item.id
          end
        end
      end

      ids
    end


    class << self
      def changes_dates_for domain_id
        sql = %Q{SELECT  dh.*, valid_from, valid_to
              FROM domain_history dh JOIN history h ON dh.historyid=h.id where dh.id=#{domain_id};}

        hash = {}
        find_by_sql(sql).each do |rec|
          hash[rec.valid_from.try(:to_time)] = [{id: rec.historyid, klass: self, param: :valid_from}] if rec.valid_from
          hash[rec.valid_to.try(:to_time)]   = [{id: rec.historyid, klass: self, param: :valid_to}]   if rec.valid_to
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
