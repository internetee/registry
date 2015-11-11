class BankLink
  module Base
    def prepend_size(value)
      value = (value || "").to_s.strip
      string = ""
      string << sprintf("%03i", value.size)
      string << value
    end
  end

  class Request
    include Base
    include ActionView::Helpers::NumberHelper

    # need controller here in order to handle random ports and domains
    # I don't want to do it but has to
    attr_accessor :type, :invoice, :controller
    def initialize(type, invoice, controller)
      @type, @invoice, @controller = type, invoice, controller
    end

    def url
      ENV["payments_#{type}_url"]
    end

    def fields
      @fields ||= (hash = {}
      hash["VK_SERVICE"]  = "1012"
      hash["VK_VERSION"]  = "008"
      hash["VK_SND_ID"]   = ENV["payments_#{type}_seller_account"]
      hash["VK_STAMP"]    = invoice.number
      hash["VK_AMOUNT"]   = number_with_precision(invoice.sum_cache, :precision => 2, :separator => ".")
      hash["VK_CURR"]     = invoice.currency
      hash["VK_REF"]      = ""
      hash["VK_MSG"]      = "Order nr. #{invoice.number}"
      hash["VK_RETURN"]   = controller.registrar_return_payment_with_url(type)
      hash["VK_CANCEL"]   = controller.registrar_return_payment_with_url(type)
      hash["VK_DATETIME"] = Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")
      hash["VK_MAC"]      = calc_mac(hash)
      hash["VK_ENCODING"] = "UTF-8"
      hash["VK_LANG"]     = "ENG"
      hash)
    end

    def calc_mac(fields)
      pars = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_STAMP VK_AMOUNT VK_CURR VK_REF VK_MSG VK_RETURN VK_CANCEL VK_DATETIME)
      data = pars.map{|e| prepend_size(fields[e]) }.join

      sign(data)
    end

    def make_transaction
      transaction = BankTransaction.where(description: fields["VK_MSG"]).first_or_initialize(
          reference_no: invoice.reference_no,
          currency: invoice.currency,
      )

      transaction.save!
    end

    private
    def sign(data)
      private_key = OpenSSL::PKey::RSA.new(File.read(ENV["payments_#{type}_seller_private"]))

      signed_data = private_key.sign(OpenSSL::Digest::SHA1.new, data)
      signed_data = Base64.encode64(signed_data).gsub(/\n|\r/, '')
      signed_data
    end
  end




  class Response
    attr_accessor :type, :params
    def initialize(type, params)
      @type, @params = type, params
    end
    def bank_public_key
      OpenSSL::X509::Certificate.new(certificate).public_key
    end
  end
end