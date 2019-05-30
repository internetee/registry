class Keyrelay < ActiveRecord::Base
  include Versions # version/keyrelay_version.rb
  include EppErrors

  belongs_to :domain

  belongs_to :requester, class_name: 'Registrar'
  belongs_to :accepter,  class_name: 'Registrar'

  has_many :legal_documents, as: :documentable

  delegate :name, to: :domain, prefix: true

  validates :domain, :key_data_public_key, :key_data_flags, :key_data_protocol,
            :key_data_alg, :auth_info_pw, presence: true
  validates :expiry_relative, duration_iso8601: true

  validate :validate_expiry_relative_xor_expiry_absolute

  after_save :touch_domain_version

  def epp_code_map
    {
      '2005' => [
        [:expiry_relative, :unknown_pattern, { value: { obj: 'relative', val: expiry_relative } }],
      ],
      '2003' => [
        # TODO: Remove only_one_parameter_allowed and other params that are validated in controller?
        [:base, :only_one_parameter_allowed, { param_1: 'relative', param_2: 'absolute' }],
        %i[key_data_public_key blank],
        %i[key_data_flags blank],
        %i[key_data_protocol blank],
        %i[key_data_alg blank],
        %i[auth_info_pw blank],
      ],
    }
  end

  def expiry
    if expiry_relative.present?
      pa_date + ISO8601::Duration.new(expiry_relative).to_seconds
    elsif expiry_absolute
      expiry_absolute
    end
  end

  def status
    if Time.zone.now > expiry
      'expired'
    else
      'pending'
    end
  end

  private

  def validate_expiry_relative_xor_expiry_absolute
    return if expiry_relative.blank? ^ expiry_absolute.blank?

    errors.add(:base, I18n.t(:only_one_parameter_allowed, param_1: 'relative', param_2: 'absolute'))
  end
end
