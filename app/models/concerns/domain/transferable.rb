module Concerns::Domain::Transferable
  extend ActiveSupport::Concern

  included do
    after_initialize :generate_auth_info, if: :new_record?
  end

  def transfer(new_registrar)
    self.registrar = new_registrar
    generate_auth_info
  end

  private

  def generate_auth_info
    self.auth_info = SecureRandom.hex
  end
end
