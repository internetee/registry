module EisBilling
  class Base

    #  crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
    # irb(main):047:0> encrypted_data = crypt.encrypt_and_sign('PLEASE CREATE INVOICE')
    # => 
    # irb(main):048:0> decrypted_back = crypt.decrypt_and_verify(encrypted_data)
    # => 
    TOKEN = 'Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw=='.freeze
    BASE_URL = ENV['eis_billing_system_base_url']
  end
end
