class Dnskey < ApplicationRecord
  include Versions # version/dnskey_version.rb
  include EppErrors

  belongs_to :domain

  validates :alg, :protocol, :flags, :public_key, presence: true, if: :validate_key_data
  validate :validate_algorithm
  validate :validate_protocol
  validate :validate_flags
  validate :validate_public_key

  before_save lambda {
    generate_digest if will_save_change_to_public_key? && !will_save_change_to_ds_digest?
  }

  before_save lambda {
    if (will_save_change_to_public_key? ||
        will_save_change_to_flags? ||
        will_save_change_to_alg? ||
        will_save_change_to_protocol?) &&
       !will_save_change_to_ds_key_tag?
      generate_ds_key_tag
    end
  }

  # IANA numbers, single authority list
  ALGORITHMS = Depp::Dnskey::ALGORITHMS.map {|pair| pair[1].to_s}.freeze
  PROTOCOLS = %w(3)
  FLAGS = %w(0 256 257) # 256 = ZSK, 257 = KSK
  DS_DIGEST_TYPE = [1,2]
  RESOLVERS = ENV['dnssec_resolver_ips'].to_s.strip.split(', ').freeze
  self.ignored_columns = %w[legacy_domain_id]

  def epp_code_map
    {
      '2005' => [
        [:alg, :invalid, { value: { obj: 'alg', val: alg },
                           values: "Valid algorithms are: #{ALGORITHMS.join(', ')}" }],
        [:protocol, :invalid, { value: { obj: 'protocol', val: protocol },
                                values: "Valid protocols are: #{PROTOCOLS.join(', ')}" }],
        [:flags, :invalid, { value: { obj: 'flags', val: flags },
                             values: "Valid protocols are: #{PROTOCOLS.join(', ')}" }],
      ],
      '2302' => [
        [:public_key, :taken, { value: { obj: 'pubKey', val: public_key } }]
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

  def validate_key_data
    alg.present? || protocol.present? || flags.present? || public_key.present?
  end

  def validate_algorithm
    return if alg.blank?
    return if ALGORITHMS.include?(alg.to_s)
    errors.add(:alg, :invalid, values: "Valid algorithms are: #{ALGORITHMS.join(', ')}")
  end

  def validate_protocol
    return if protocol.blank?
    return if PROTOCOLS.include?(protocol.to_s)
    errors.add(:protocol, :invalid, values: "Valid protocols are: #{PROTOCOLS.join(', ')}")
  end

  def validate_flags
    return if flags.blank?
    return if FLAGS.include?(flags.to_s)

    errors.add(:flags, :invalid, values: "Valid flags are: #{FLAGS.join(', ')}")
  end

  def public_key=(value)
    super(value.strip.delete(' '))
  end

  def generate_digest
    return unless flags == 257 || flags == 256 # require ZoneFlag, but optional SecureEntryPoint

    self.ds_alg = alg
    self.ds_digest_type = Setting.ds_digest_type if ds_digest_type.blank? || !DS_DIGEST_TYPE.include?(ds_digest_type)

    flags_hex = self.class.int_to_hex(flags)
    protocol_hex = self.class.int_to_hex(protocol)
    alg_hex = self.class.int_to_hex(alg)

    hex = [domain.name_in_wire_format, flags_hex, protocol_hex, alg_hex, public_key_hex].join
    bin = self.class.hex_to_bin(hex)

    case ds_digest_type
    when 1
      self.ds_digest = Digest::SHA1.hexdigest(bin).upcase
    when 2
      self.ds_digest = Digest::SHA256.hexdigest(bin).upcase
    end
  end

  def public_key_hex
    self.class.bin_to_hex(Base64.decode64(public_key))
  end

  def generate_ds_key_tag
    return unless flags == 257 || flags == 256 # require ZoneFlag, but optional SecureEntryPoint
    pk = public_key.gsub(' ', '')
    wire_format = [flags, protocol, alg].pack('S!>CC')
    wire_format += Base64.decode64(pk)

    c = 0
    wire_format.each_byte.with_index do |b, i|
      c += if i.even?
             b << 8
           else
             b
           end
    end

    self.ds_key_tag = ((c & 0xFFFF) + (c >> 16)) & 0xFFFF
  end

  def validate_public_key
    return if Dnskey.pub_key_base64?(public_key)

    errors.add(:public_key, :invalid)
  end

  def self.new_from_csync(cdnskey:, domain:)
    cdnskey ||= '' # avoid strip() issues for gibberish key

    flags, proto, alg, pub = cdnskey.strip.split(' ')
    Dnskey.new(domain: domain, flags: flags, protocol: proto, alg: alg, public_key: pub)
  end

  def ds_rr
    # Break the DNSSEC trust chain as we are not able to fake RRSIG's
    Dnsruby::Dnssec.clear_trust_anchors
    Dnsruby::Dnssec.clear_trusted_keys

    # Basically let's configure domain as root anchor. We can still verify
    # RRSIG's / DNSKEY targeted by DS of this domain
    generate_digest
    generate_ds_key_tag
    Dnsruby::RR.create("#{domain.name}. 3600 IN DS #{ds_key_tag} #{ds_alg} " \
    "#{ds_digest_type} #{ds_digest}")
  end

  class << self
    def int_to_hex(num)
      num = num.to_s(16)
      num.prepend('0') if num.length.odd?
    end

    def hex_to_bin(num)
      num.scan(/../).map(&:hex).pack('c*')
    end

    def bin_to_hex(num)
      num.each_byte.map { |b| format('%02X', b) }.join
    end

    def pub_key_base64?(pub)
      return unless pub.is_a?(String)

      Base64.strict_encode64(Base64.strict_decode64(pub)) == pub
    rescue ArgumentError
      false
    end
  end
end
