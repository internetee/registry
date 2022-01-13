module EisBilling
  class Base

    #  crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
    # irb(main):047:0> encrypted_data = crypt.encrypt_and_sign('PLEASE CREATE INVOICE')
    # => "HFW8ADSIrjyD9cbH4H5Rk3MY/ZfhV85IlnGl7YI2CQ==--OvlWMMiTLLotgdfT--/ffejEDaIGFfz7FzzNSlYA=="
    # irb(main):048:0> decrypted_back = crypt.decrypt_and_verify(encrypted_data)
    # => "PLEASE CREATE INVOICE"
    TOKEN = "Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw==".freeze
    BASE_URL = "http://eis_billing_system:3000".freeze

    protected

  end
end
