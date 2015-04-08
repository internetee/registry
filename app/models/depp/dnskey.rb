module Depp
  class Dnskey
    FLAGS = [
      ['0 - not for DNSSEC validation', 0],
      ['256 - ZSK', 256],
      ['257 - KSK', 257]
    ]

    ALGORITHMS = [
      ['3 - DSA/SHA-1', 3],
      ['5 - RSA/SHA-1', 5],
      ['6 - DSA-NSEC3-SHA1', 6],
      ['7 - RSASHA1-NSEC3-SHA1', 7],
      ['8 - RSA/SHA-256', 8],
      ['252 - Reserved for Indirect Keys', 252],
      ['253 - Private algorithm', 253],
      ['254 - Private algorithm OID', 254],
      ['255 - Reserved', 255]
    ]

    PROTOCOLS = [3]

    DS_DIGEST_TYPES = [1, 2]
  end
end
