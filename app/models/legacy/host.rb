module Legacy
  class Host < Db
    self.table_name = :host

    has_many :host_ipaddr_maps, foreign_key: :hostid
  end
end
