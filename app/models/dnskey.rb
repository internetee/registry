class Dnskey < ActiveRecord::Base
  include Versions # version/dnskey_version.rb
  include EppErrors

  belongs_to :domain

  validates :alg, :protocol, :flags, :public_key, presence: true, if: :validate_key_data
  validate :validate_algorithm
  validate :validate_protocol
  validate :validate_flags

  before_save -> { generate_digest if public_key_changed? && !ds_digest_changed? }

  before_save lambda {
    if (public_key_changed? || flags_changed? || alg_changed? || protocol_changed?) && !ds_key_tag_changed?
      generate_ds_key_tag
    end
  }

  ALGORITHMS = Depp::Dnskey::ALGORITHMS.map { |pair| pair[1].to_s }.freeze # IANA numbers, single authority list
  PROTOCOLS = %w[3].freeze
  FLAGS = %w[0 256 257].freeze # 256 = ZSK, 257 = KSK
  DS_DIGEST_TYPE = [1, 2].freeze

  def epp_code_map
    {
      '2005' => [
        [:alg, :invalid, { value: { obj: 'alg', val: alg }, values: ALGORITHMS.join(', ') }],
        [:protocol, :invalid, { value: { obj: 'protocol', val: protocol }, values: PROTOCOLS.join(', ') }],
        [:flags, :invalid, { value: { obj: 'flags', val: flags }, values: FLAGS.join(', ') }],
      ],
      '2302' => [
        [:public_key, :taken, { value: { obj: 'pubKey', val: public_key } }],
      ],
      '2303' => [
        [:base, :dnskey_not_found, { value: { obj: 'pubKey', val: public_key } }],
      ],
      '2306' => [
        %i[alg blank],
        %i[protocol blank],
        %i[flags blank],
        %i[public_key blank],
      ],
    }
  end

  def validate_key_data
    alg.present? || protocol.present? || flags.present? || public_key.present?
  end

  def validate_algorithm
    return if alg.blank?
    return if ALGORITHMS.include?(alg.to_s)

    errors.add(:alg, :invalid, values: ALGORITHMS.join(', '))
  end

  def validate_protocol
    return if protocol.blank?
    return if PROTOCOLS.include?(protocol.to_s)

    errors.add(:protocol, :invalid, values: PROTOCOLS.join(', '))
  end

  def validate_flags
    return if flags.blank?
    return if FLAGS.include?(flags.to_s)

    errors.add(:flags, :invalid, values: FLAGS.join(', '))
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

    if ds_digest_type == 1
      self.ds_digest = Digest::SHA1.hexdigest(bin).upcase
    elsif ds_digest_type == 2
      self.ds_digest = Digest::SHA256.hexdigest(bin).upcase
    end
  end

  def public_key_hex
    self.class.bin_to_hex(Base64.decode64(public_key))
  end

  def generate_ds_key_tag
    return unless flags == 257 || flags == 256 # require ZoneFlag, but optional SecureEntryPoint

    pk = public_key.delete(' ')
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

  class << self
    def int_to_hex(s)
      s = s.to_s(16)
      s.prepend('0') if s.length.odd?
    end

    def hex_to_bin(s)
      s.scan(/../).map(&:hex).pack('c*')
    end

    def bin_to_hex(s)
      s.each_byte.map { |b| format('%02X', b) }.join
    end
  end
end
