module Depp
  class Dnskey
    FLAGS = [
      ['0 - not for DNSSEC validation', 0],
      ['256 - ZSK', 256],
      ['257 - KSK', 257],
    ].freeze

    ALGORITHMS = [
      ['3 - DSA/SHA-1', 3],
      ['5 - RSA/SHA-1', 5],
      ['6 - DSA-NSEC3-SHA1', 6],
      ['7 - RSASHA1-NSEC3-SHA1', 7],
      ['8 - RSA/SHA-256', 8],
      ['10 - RSA/SHA-512', 10],
      ['13 - ECDSA Curve P-256 with SHA-256', 13],
      ['14 - ECDSA Curve P-384 with SHA-384', 14],
    ].freeze

    PROTOCOLS = [3].freeze

    DS_DIGEST_TYPES = [1, 2].freeze
  end
end
