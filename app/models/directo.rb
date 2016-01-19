class Directo < ActiveRecord::Base
  belongs_to :item, polymorphic: true

  def self.send_receipts
    new_trans = BankTransaction.where(in_directo: false)
    new_trans.find_in_batches(batch_size: 10).each do |group|
      mappers = {} # need them as no direct connection between transaction and invoice
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.invoices {
          group.each do |transaction|
            invoice = transaction.invoice
            next unless invoice
            num     = transaction.invoice_num
            mappers[num] = transaction

            xml.invoice(
                "SalesAgent"  => Setting.directo_sales_agent,
                "Number"      => num,
                "InvoiceDate" => (transaction.paid_at||transaction.created_at).strftime("%Y-%m-%dT%H:%M:%S"),
                "PaymentTerm" => Setting.directo_receipt_payment_term,
                "Currency"    => transaction.currency,
                "CustomerCode"=> invoice.buyer.try(:directo_handle)
            ){
              xml.line(
                  "ProductID"=> Setting.directo_receipt_product_name,
                  "Quantity" => 1,
                  "UnitPriceWoVAT" =>ActionController::Base.helpers.number_with_precision(invoice.sum_cache/(1+invoice.vat_prc), precision: 2, separator: "."),
                  "ProductName" => transaction.description
              )
            }
          end
        }
      end

      data = builder.to_xml.gsub("\n",'')
      response = RestClient::Request.execute(url: ENV['directo_invoice_url'], method: :post, payload: {put: "1", what: "invoice", xmldata: data}, verify_ssl: false).to_s
      dump_result_to_db(mappers, response)
    end
  end

  def self.dump_result_to_db mappers, xml
    Nokogiri::XML(xml).css("Result").each do |res|
      obj = mappers[res.attributes["docid"].value.to_i]
      obj.directo_records.first_or_create!(response: res.as_json.to_h)
      obj.update_columns(in_directo: true)
    end
  end
end
