module Payments
  class BankLink < Base
    # TODO: Remove magic numbers, convert certain fields to proper constants
    # TODO: Remove hashrockets
    def form_fields
      @fields ||= (hash = {}
                   hash["VK_SERVICE"]  = "1012"
                   hash["VK_VERSION"]  = "008"
                   hash["VK_SND_ID"]   = seller_account
                   hash["VK_STAMP"]    = invoice.number
                   hash["VK_AMOUNT"]   = number_with_precision(invoice.sum_cache, :precision => 2, :separator => ".")
                   hash["VK_CURR"]     = invoice.currency
                   hash["VK_REF"]      = ""
                   hash["VK_MSG"]      = invoice.order
                   hash["VK_RETURN"]   = return_url
                   hash["VK_CANCEL"]   = return_url
                   hash["VK_DATETIME"] = Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")
                   hash["VK_MAC"]      = calc_mac(hash)
                   hash["VK_ENCODING"] = "UTF-8"
                   hash["VK_LANG"]     = "ENG"
                   hash)
    end

    def valid_response?
      return false unless response

      case response["VK_SERVICE"]
      when "1111"
        validate_success && validate_amount && validate_currency
      when "1911"
        validate_cancel
      else
        false
      end
    end

    private

    def validate_success
      pars = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_REC_ID VK_STAMP VK_T_NO VK_AMOUNT VK_CURR
        VK_REC_ACC VK_REC_NAME VK_SND_ACC VK_SND_NAME VK_REF VK_MSG VK_T_DATETIME).freeze

      @validate_success ||= (
        data = pars.map{|e| prepend_size(response[e]) }.join
        verify_mac(data, response["VK_MAC"])
      )
    end

    def validate_cancel
      pars = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_REC_ID VK_STAMP VK_REF VK_MSG).freeze
      @validate_cancel ||= (
        data = pars.map{|e| prepend_size(response[e]) }.join
        verify_mac(data, response["VK_MAC"])
      )
    end

    def validate_amount
      source = number_with_precision(BigDecimal.new(response["VK_AMOUNT"].to_s), precision: 2, separator: ".")
      target = number_with_precision(invoice.sum_cache, precision: 2, separator: ".")

      source == target
    end

    def validate_currency
      invoice.currency == response["VK_CURR"]
    end

    def sign(data)
      private_key = OpenSSL::PKey::RSA.new(File.read(seller_certificate))

      signed_data = private_key.sign(OpenSSL::Digest::SHA1.new, data)
      signed_data = Base64.encode64(signed_data).gsub(/\n|\r/, '')
      signed_data
    end

    def verify_mac(data, mac)
      bank_public_key = OpenSSL::X509::Certificate.new(File.read(bank_certificate)).public_key
      bank_public_key.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(mac), data)
    end

    def calc_mac(fields)
      pars = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_STAMP VK_AMOUNT VK_CURR VK_REF
                    VK_MSG VK_RETURN VK_CANCEL VK_DATETIME).freeze
      data = pars.map{|e| prepend_size(fields[e]) }.join

      sign(data)
    end

    def prepend_size(value)
      value = (value || "").to_s.strip
      string = ""
      string << sprintf("%03i", value.size)
      string << value
    end

    def seller_account
      ENV["#{type}_seller_account"]
    end

    def seller_certificate
      ENV["#{type}_seller_certificate"]
    end

    def bank_certificate
      ENV["#{type}_bank_certificate"]
    end
  end
end
