class Registrar < ActiveRecord::Base
  belongs_to :country
  has_many :domains
  has_many :ns_sets
  has_many :epp_users
  has_many :users
  has_many :domain_transfers, foreign_key: 'transfer_to_id'

  def to_s
    name
  end

  class << self
    def search_by_query(query)
      res = search(name_or_reg_no_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v[:name]} (#{v[:reg_no]})" } }
    end
  end
end
