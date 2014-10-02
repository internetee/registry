class Dnskey < ActiveRecord::Base
  include EppErrors

  belongs_to :domain

  validates :alg, :protocol, :flags, :public_key, presence: true
  validate :validate_algorithm
  validate :validate_protocol
  validate :validate_flags

  def epp_code_map
    {
      '2005' => [
        [:alg, :invalid, { value: { obj: 'alg', val: alg } }],
        [:protocol, :invalid, { value: { obj: 'protocol', val: protocol } }],
        [:flags, :invalid, { value: { obj: 'flags', val: flags } }]
      ],
      '2303' => [
        [:base, :dnskey_not_found, { value: { obj: 'pubKey', val: public_key } }]
      ],
      '2306' => [
        [:alg, :blank],
        [:protocol, :blank],
        [:flags, :blank],
        [:public_key, :blank]
      ]
    }
  end

  def validate_algorithm
    return if %w(3 5 6 7 8 252 253 254 255).include?(alg.to_s)
    errors.add(:alg, :invalid)
  end

  def validate_protocol
    return if %w(3).include?(protocol.to_s)
    errors.add(:protocol, :invalid)
  end

  def validate_flags
    return if %w(0 256 257).include?(flags.to_s)
    errors.add(:flags, :invalid)
  end
end
