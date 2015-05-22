require 'open3'

# rubocop: disable Metrics/ClassLength
class ApiUser < User
  include EppErrors
  def epp_code_map # rubocop:disable Metrics/MethodLength
    {
      '2306' => [ # Parameter policy error
        [:password, :blank]
      ]
    }
  end

  # TODO: should have max request limit per day
  belongs_to :registrar
  has_many :certificates

  validates :username, :password, :registrar, :roles, presence: true
  validates :username, uniqueness: true

  attr_accessor :registrar_typeahead

  ROLES = %w(super epp billing) # should not match to admin roles

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  after_initialize :set_defaults
  def set_defaults
    return unless new_record?
    self.active = true unless active_changed?
  end

  def registrar_typeahead
    @registrar_typeahead || registrar || nil
  end

  def to_s
    username
  end

  def queued_messages
    registrar.messages.queued
  end

  def registrar_pki_ok?(crt)
    certificates.registrar.exists?(crt: crt)
  end

  def api_pki_ok?(crt)
    certificates.api.exists?(crt: crt)
  end

  class << self
    def find_by_idc_data(idc_data)
      return false if idc_data.blank?
      identity_code = idc_data.scan(/serialNumber=(\d+)/).flatten.first

      find_by(identity_code: identity_code)
    end
  end
end
# rubocop: enable Metrics/ClassLength
