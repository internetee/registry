class Dnskey < ActiveRecord::Base
  include EppErrors

  belongs_to :domain

  validate :validate_algorithm
  validate :validate_protocol

  def epp_code_map
    {
      '2005' => [
        [:alg, :invalid, { value: { obj: 'alg', val: alg } }],
        [:protocol, :invalid, { value: { obj: 'protocol', val: protocol } }],
      ],
      '2306' => [
        [:ipv4, :blank]
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
end
