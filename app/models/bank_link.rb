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
      hash["VK_AMOUNT"]   = number_with_precision(invoice.total, :precision => 2, :separator => ".")
      hash["VK_CURR"]     = invoice.currency
      hash["VK_REF"]      = ""
      hash["VK_MSG"]      = invoice.order
      hash["VK_RETURN"]   = controller.registrar_return_payment_with_url(type)
      hash["VK_CANCEL"]   = controller.registrar_return_payment_with_url(type)
      hash["VK_DATETIME"] = Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")
      hash["VK_MAC"]      = calc_mac(hash)
      hash["VK_ENCODING"] = "UTF-8"
      hash["VK_LANG"]     = "ENG"
      hash)
    end

    def calc_mac(fields)
      pars = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_STAMP VK_AMOUNT VK_CURR VK_REF
                    VK_MSG VK_RETURN VK_CANCEL VK_DATETIME).freeze
      data = pars.map{|e| prepend_size(fields[e]) }.join

      sign(data)
    end

    def make_transaction
      transaction = BankTransaction.where(description: fields["VK_MSG"]).first_or_initialize(
          reference_no: invoice.reference_no,
          currency:     invoice.currency,
          iban:         invoice.seller_iban
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
    include Base
    include ActionView::Helpers::NumberHelper

    attr_accessor :type, :params, :invoice
    def initialize(type, params)
      @type, @params = type, params

      @invoice = Invoice.find_by(number: params["VK_STAMP"]) if params["VK_STAMP"].present?
    end

    def valid?
      !!validate
    end

    def ok?
      params["VK_SERVICE"] == "1111"
    end

    def complete_payment
      if valid?
        transaction                 = BankTransaction.find_by(description: params["VK_MSG"])
        transaction.sum             = BigDecimal.new(params["VK_AMOUNT"].to_s)
        transaction.bank_reference  = params['VK_T_NO']
        transaction.buyer_bank_code = params["VK_SND_ID"]
        transaction.buyer_iban      = params["VK_SND_ACC"]
        transaction.buyer_name      = params["VK_SND_NAME"]
        transaction.paid_at         = Time.parse(params["VK_T_DATETIME"])
        transaction.save!

        transaction.autobind_invoice
      end
    end



    def validate
      case params["VK_SERVICE"]
        when "1111"
          validate_success && validate_amount && validate_currency
        when "1911"
          validate_cancel
        else
          false
      end
    end

    def validate_success
      pars = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_REC_ID VK_STAMP VK_T_NO VK_AMOUNT VK_CURR
        VK_REC_ACC VK_REC_NAME VK_SND_ACC VK_SND_NAME VK_REF VK_MSG VK_T_DATETIME).freeze

      @validate_success ||= (
        data = pars.map{|e| prepend_size(params[e]) }.join
        verify_mac(data, params["VK_MAC"])
      )
    end

    def validate_cancel
      pars = %w(VK_SERVICE VK_VERSION VK_SND_ID VK_REC_ID VK_STAMP VK_REF VK_MSG).freeze
      @validate_cancel ||= (
        data = pars.map{|e| prepend_size(params[e]) }.join
        verify_mac(data, params["VK_MAC"])
      )
    end

    def validate_amount
      source = number_with_precision(BigDecimal.new(params["VK_AMOUNT"].to_s), precision: 2, separator: ".")
      target = number_with_precision(invoice.total, precision: 2, separator: ".")

      source == target
    end

    def validate_currency
      invoice.currency == params["VK_CURR"]
    end


    def verify_mac(data, mac)
      bank_public_key = OpenSSL::X509::Certificate.new(File.read(ENV["payments_#{type}_bank_certificate"])).public_key
      bank_public_key.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(mac), data)
    end
  end
end
