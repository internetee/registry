class Registrar < ActiveRecord::Base
  belongs_to :country
  has_many :domains, :dependent => :restrict_with_error
  has_many :ns_sets
  has_many :epp_users
  has_many :users

  validates :name, :reg_no, :address, :country, presence: true
  validates :name, :reg_no, uniqueness: true


  def domain_transfers
    at = DomainTransfer.arel_table
    DomainTransfer.where(
      at[:transfer_to_id].eq(id).or(
        at[:transfer_from_id].eq(id)
      )
    )
  end

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
