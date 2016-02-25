class Directo < ActiveRecord::Base
  belongs_to :item, polymorphic: true

  def self.send_receipts
    new_trans = Invoice.where(invoice_type: "DEB", in_directo: false).where.not(cancelled_at: nil)
    new_trans.find_in_batches(batch_size: 10).each do |group|
      mappers = {} # need them as no direct connection between invoice
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.invoices {
          group.each do |invoice|
            next if invoice.account_activity.nil? || invoice.account_activity.bank_transaction.nil?
            # next if invoice.account_activity.bank_transaction.sum.nil? || invoice.account_activity.bank_transaction.sum != invoice.sum_cache

            num     = invoice.number
            mappers[num] = invoice
            xml.invoice(
                "SalesAgent"  => Setting.directo_sales_agent,
                "Number"      => num,
                "InvoiceDate" => invoice.created_at.strftime("%Y-%m-%dT%H:%M:%S"),
                "PaymentTerm" => Setting.directo_receipt_payment_term,
                "Currency"    => invoice.currency,
                "CustomerCode"=> invoice.buyer.try(:directo_handle)
            ){
              xml.line(
                  "ProductID"      => Setting.directo_receipt_product_name,
                  "Quantity"       => 1,
                  "UnitPriceWoVAT" => ActionController::Base.helpers.number_with_precision(invoice.sum_cache/(1+invoice.vat_prc), precision: 2, separator: "."),
                  "ProductName"    => invoice.description
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
      obj.directo_records.create!(response: res.as_json.to_h)
      obj.update_columns(in_directo: true)
      Rails.logger.info("[DIRECTO] Invoice #{res.attributes["docid"].value} was pushed and return is #{res.as_json.to_h.inspect}")
    end
  end


  def self.send_monthly_invoices
    product_ids    = {"ee" => "01EE", "com.ee" => "02COM", "pri.ee" => "03PRI", "fie.ee"=>"04FIE", "med.ee" => "05MED"}
    month          = Time.now - 1.month
    invoices_until = month.end_of_month
    # pochemu registrar has_many :accounts

    activity_scope = AccountActivity.where(activity_type: [CREATE, RENEW])
    Registrar.joins(:account).find_each do |registrar|
      next unless registrar.cash_account
      counter = Counter.new
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        activity_scope.where(account_id: registrar.cash_account)

        xml.invoices{
          xml.invoice("Number"=>"13980",
                      "InvoiceDate"=>invoices_until.strftime("%Y-%m-%d"),
                      "PaymentTerm"=>"E",
                      "CustomerCode"=>registrar.directo_handle,
                      "Language"=>"",
                      "Currency"=>"EUR",
                      "SalesAgent"=>Setting.directo_sales_agent){
            xml.line("RN" => counter.next, "RR"=>1, "ProductName"=> "Domeenide registreerimine - Juuli 2015")
            activity_scope.where(account_id: registrar.account_ids).each do |activity|
              xml.line("RN"=>counter.next, "RR"=>"2", "ProductID"=>"01EE", "Quantity"=>"1911", "Unit"=>"tk", "ProductName"=>".ee registreerimine: 1 aasta", "UnitPriceWoVAT"=>"9.00")
            end
          }
        }
      end

    end
  end
end

=begin
RN - incremental
RR - grouping of rows - is same for rows where sum is devided to more than one year eg. 7€ - 7€ - 7€ for 3 year 21€ domains

<?xml version="1.0" encoding="UTF-8"?>

<invoices>
  <!-- Period (UTC) : 2015-06-30 21:00:00 to 2015-07-31 21:00:00 -->
  <!-- Executed at : Thu Aug 13 09:32:51 2015 -->
  <invoice Number="13980" InvoiceDate="2015-07-31" PaymentTerm="E" CustomerCode="REGISTRAR2" Language="" Currency="EUR" SalesAgent="NIMI">
    <line RN="1" RR="1" ProductName="Domeenide registreerimine - Juuli 2015" />
    <line RN="2" RR="2" ProductID="01EE" Quantity="1911" Unit="tk" ProductName=".ee registreerimine: 1 aasta" UnitPriceWoVAT="9.00" />
    <line RN="3" RR="3" ProductID="01EE" Quantity="154" Unit="tk" ProductName=".ee registreerimine: 2 aastat" UnitPriceWoVAT="9.00" />
    <line RN="4" RR="3" ProductID="01EE" Quantity="154" Unit="tk" ProductName=".ee registreerimine: 2 aastat" UnitPriceWoVAT="8.00" StartDate="2016-07-31" EndDate="2016-07-31" />
    <line RN="5" RR="5" ProductID="01EE" Quantity="170" Unit="tk" ProductName=".ee registreerimine: 3 aastat" UnitPriceWoVAT="9.00" />
    <line RN="6" RR="5" ProductID="01EE" Quantity="170" Unit="tk" ProductName=".ee registreerimine: 3 aastat" UnitPriceWoVAT="8.00" StartDate="2016-07-31" EndDate="2016-07-31" />
    <line RN="7" RR="5" ProductID="01EE" Quantity="170" Unit="tk" ProductName=".ee registreerimine: 3 aastat" UnitPriceWoVAT="7.00" StartDate="2017-07-31" EndDate="2017-07-31" />
    <line RN="8" RR="8" ProductID="03PRI" Quantity="2" Unit="tk" ProductName=".pri.ee registreerimine: 1 aasta" UnitPriceWoVAT="9.00" />
    <line RN="9" RR="9" ProductID="04FIE" Quantity="1" Unit="tk" ProductName=".fie.ee registreerimine: 1 aasta" UnitPriceWoVAT="9.00" />
    <line RN="10" RR="10" ProductID="02COM" Quantity="11" Unit="tk" ProductName=".com.ee registreerimine: 1 aasta" UnitPriceWoVAT="9.00" />
    <line RN="11" RR="11" ProductID="ETTEM06" Quantity="-1" Unit="tk" ProductName="Domeenide ettemaks" UnitPriceWoVAT="1000.00" />
  </invoice>
</invoices>
=end
