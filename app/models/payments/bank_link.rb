module Payments
  class BankLink < Base
    BANK_LINK_VERSION = '008'

    NEW_TRANSACTION_SERVICE_NUMBER    = '1012'
    SUCCESSFUL_PAYMENT_SERVICE_NUMBER = '1111'
    CANCELLED_PAYMENT_SERVICE_NUMBER  = '1911'

    NEW_MESSAGE_KEYS     = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_STAMP VK_AMOUNT
                              VK_CURR VK_REF VK_MSG VK_RETURN VK_CANCEL
                              VK_DATETIME).freeze
    SUCCESS_MESSAGE_KEYS = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_REC_ID VK_STAMP
                              VK_T_NO VK_AMOUNT VK_CURR VK_REC_ACC VK_REC_NAME
                              VK_SND_ACC VK_SND_NAME VK_REF VK_MSG
                              VK_T_DATETIME).freeze
    CANCEL_MESSAGE_KEYS  = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_REC_ID VK_STAMP
                              VK_REF VK_MSG).freeze

    def form_fields
      hash = {}
      hash["VK_SERVICE"]  = NEW_TRANSACTION_SERVICE_NUMBER
      hash["VK_VERSION"]  = BANK_LINK_VERSION
      hash["VK_SND_ID"]   = seller_account
      hash["VK_STAMP"]    = invoice.number
      hash["VK_AMOUNT"]   = number_with_precision(invoice.total, precision: 2, separator: ".")
      hash["VK_CURR"]     = invoice.currency
      hash["VK_REF"]      = ""
      hash["VK_MSG"]      = invoice.order
      hash["VK_RETURN"]   = return_url
      hash["VK_CANCEL"]   = return_url
      hash["VK_DATETIME"] = Time.zone.now.strftime("%Y-%m-%dT%H:%M:%S%z")
      hash["VK_MAC"]      = calc_mac(hash)
      hash["VK_ENCODING"] = "UTF-8"
      hash["VK_LANG"]     = "ENG"
      hash
    end

    def valid_response_from_intermediary?
      return false unless response

      case response["VK_SERVICE"]
      when SUCCESSFUL_PAYMENT_SERVICE_NUMBER
        valid_successful_transaction?
      when CANCELLED_PAYMENT_SERVICE_NUMBER
        valid_cancel_notice?
      else
        false
      end
    end

    def complete_transaction
      return unless valid_successful_transaction?

      transaction = BankTransaction.find_by(
        description: invoice.order,
        currency: invoice.currency,
        iban: invoice.seller_iban
      )

      transaction.sum             = response['VK_AMOUNT']
      transaction.bank_reference  = response['VK_T_NO']
      transaction.buyer_bank_code = response["VK_SND_ID"]
      transaction.buyer_iban      = response["VK_SND_ACC"]
      transaction.buyer_name      = response["VK_SND_NAME"]
      transaction.paid_at         = Time.parse(response["VK_T_DATETIME"])

      transaction.save!
      transaction.autobind_invoice
    end

    def settled_payment?
      response["VK_SERVICE"] == SUCCESSFUL_PAYMENT_SERVICE_NUMBER
    end

    private

    def valid_successful_transaction?
      return false unless valid_success_notice?
      return false unless valid_amount?
      return false unless valid_currency?
      true
    end

    def valid_cancel_notice?
      valid_mac?(response, CANCEL_MESSAGE_KEYS)
    end

    def valid_success_notice?
      valid_mac?(response, SUCCESS_MESSAGE_KEYS)
    end

    def valid_amount?
      source = number_with_precision(
        BigDecimal.new(response["VK_AMOUNT"]), precision: 2, separator: "."
      )
      target = number_with_precision(
        invoice.total, precision: 2, separator: "."
      )

      source == target
    end

    def valid_currency?
      invoice.currency == response["VK_CURR"]
    end

    def sign(data)
      private_key = OpenSSL::PKey::RSA.new(File.read(seller_certificate))
      signed_data = private_key.sign(OpenSSL::Digest::SHA1.new, data)
      signed_data = Base64.encode64(signed_data).gsub(/\n|\r/, '')
      signed_data
    end

    def calc_mac(fields)
      pars = NEW_MESSAGE_KEYS
      data = pars.map { |e| prepend_size(fields[e]) }.join
      sign(data)
    end

    def valid_mac?(hash, keys)
      data = keys.map { |e| prepend_size(hash[e]) }.join
      verify_mac(data, hash["VK_MAC"])
    end

    def verify_mac(data, mac)
      bank_public_key = OpenSSL::X509::Certificate.new(File.read(bank_certificate)).public_key
      bank_public_key.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(mac), data)
    end

    def prepend_size(value)
      value = (value || "").to_s.strip
      string = ""
      string << format("%03i", value.size)
      string << value
    end

    def seller_account
      ENV["payments_#{type}_seller_account"]
    end

    def seller_certificate
      ENV["payments_#{type}_seller_private"]
    end

    def bank_certificate
      ENV["payments_#{type}_bank_certificate"]
    end
  end
end
