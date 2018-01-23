module Concerns::Domain::Transferable
  extend ActiveSupport::Concern

  included do
    after_initialize :generate_transfer_code, if: :new_record?
  end

  def transfer(new_registrar)
    self.registrar = new_registrar
    regenerate_transfer_code
  end

  private

  def generate_transfer_code
    self.transfer_code = SecureRandom.hex
  end

  alias_method :regenerate_transfer_code, :generate_transfer_code
end
