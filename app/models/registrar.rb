class Registrar < ActiveRecord::Base
  has_many :domains, dependent: :restrict_with_error
  has_many :contacts, dependent: :restrict_with_error
  has_many :api_users, dependent: :restrict_with_error
  has_many :messages

  validates :name, :reg_no, :address, :country, :email, presence: true
  validates :name, :reg_no, uniqueness: true

  validates :email, :billing_email, format: /@/, allow_blank: true

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

  def country
    Country.new(country_code)
  end

  class << self
    def search_by_query(query)
      res = search(name_or_reg_no_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v[:name]} (#{v[:reg_no]})" } }
    end
  end
end
