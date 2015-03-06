class Registrar < ActiveRecord::Base
  include Versions # version/registrar_version.rb

  has_many :domains, dependent: :restrict_with_error
  has_many :contacts, dependent: :restrict_with_error
  has_many :api_users, dependent: :restrict_with_error
  has_many :messages
  belongs_to :country_deprecated, foreign_key: :country_id

  validates :name, :reg_no, :country_code, :email, presence: true
  validates :name, :reg_no, uniqueness: true
  validate :set_code, if: :new_record?
  after_save :touch_domains_version

  validates :email, :billing_email, format: /@/, allow_blank: true

  class << self
    def search_by_query(query)
      res = search(name_or_reg_no_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v[:name]} (#{v[:reg_no]})" } }
    end
  end

  def domain_transfers
    at = DomainTransfer.arel_table
    DomainTransfer.where(
      at[:transfer_to_id].eq(id).or(
        at[:transfer_from_id].eq(id)
      )
    )
  end

  def address
    [street, city, state, zip].reject(&:blank?).compact.join(', ')
  end

  def to_s
    name
  end

  def country
    Country.new(country_code)
  end

  def code=(code)
    self[:code] = code if new_record?
  end

  private

  def set_code
    return false if name.blank?
    new_code = name.parameterize

    # ensure code is always uniq automatically for a new record
    seq = 1
    while self.class.find_by_code(new_code)
      new_code += seq.to_s
      seq += 1
    end

    self.code = new_code
  end
end
