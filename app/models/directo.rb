class Directo < ActiveRecord::Base
  DOMAIN_TO_PRODUCT = {"ee" => "01EE", "com.ee" => "02COM", "pri.ee" => "03PRI", "fie.ee"=>"04FIE", "med.ee" => "05MED"}.freeze
  belongs_to :item, polymorphic: true

  def self.send_receipts
    new_trans = Invoice.where(invoice_type: "DEB", in_directo: false).where(cancelled_at: nil)
    total     = new_trans.count
    counter   = 0
    Rails.logger.info("[DIRECTO] Will try to send #{total} invoices")

    new_trans.find_in_batches(batch_size: 10).each do |group|
      mappers = {} # need them as no direct connection between invoice
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.invoices {
          group.each do |invoice|

            if invoice.account_activity.nil? || invoice.account_activity.bank_transaction.nil? ||
                invoice.account_activity.bank_transaction.sum.nil? || invoice.account_activity.bank_transaction.sum != invoice.sum_cache
              Rails.logger.info("[DIRECTO] Invoice #{invoice.number} has been skipped")
              next
            end
            counter += 1

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

    STDOUT << "#{Time.zone.now.utc} - Directo receipts sending finished. #{counter} of #{total} are sent\n"
  end

  def self.dump_result_to_db mappers, xml
    Nokogiri::XML(xml).css("Result").each do |res|
      obj = mappers[res.attributes["docid"].value.to_i]
      obj.directo_records.create!(response: res.as_json.to_h, invoice_number: obj.number)
      obj.update_columns(in_directo: true)
      Rails.logger.info("[DIRECTO] Invoice #{res.attributes["docid"].value} was pushed and return is #{res.as_json.to_h.inspect}")
    end
  end


  def self.send_monthly_invoices(debug: false)
    @debug         = debug
    I18n.locale    = :et
    month          = Time.now - 1.month
    invoices_until = month.end_of_month
    date_format    = "%Y-%m-%d"
    invoice_counter= Counter.new

    min_directo    = Setting.directo_monthly_number_min.presence.try(:to_i)
    max_directo    = Setting.directo_monthly_number_max.presence.try(:to_i)
    last_directo   = [Setting.directo_monthly_number_last.presence.try(:to_i), min_directo].compact.max || 0
    if max_directo && max_directo <= last_directo
      raise "Directo counter is out of period (max allowed number is smaller than last counter number)"
    end

    directo_next = last_directo
    Registrar.where.not(test_registrar: true).find_each do |registrar|
      unless registrar.cash_account
        Rails.logger.info("[DIRECTO] Monthly invoice for registrar #{registrar.id} has been skipped as it doesn't has cash_account")
        next
      end
      counter = Counter.new(1)
      items   = {}
      registrar_activities = AccountActivity.where(account_id: registrar.account_ids).where("created_at BETWEEN ? AND ?",month.beginning_of_month, month.end_of_month)

      # adding domains items
      registrar_activities.where(activity_type: [AccountActivity::CREATE, AccountActivity::RENEW]).each do |activity|
        pricelist    = load_activity_pricelist(activity)
        unless pricelist
          Rails.logger.error("[DIRECTO] Skipping activity #{activity.id} as pricelist not found")
          next
        end

        pricelist.years_amount.times do |i|
          year = i+1
          hash = {
              "ProductID"      => DOMAIN_TO_PRODUCT[pricelist.category],
              "Unit"           => "tk",
              "ProductName"    => ".#{pricelist.category} registreerimine: #{pricelist.years_amount} aasta",
              "UnitPriceWoVAT" => pricelist.price_decimal/pricelist.years_amount
          }
          hash["StartDate"] = (activity.created_at + (year-1).year).end_of_month.strftime(date_format)     if year > 1
          hash["EndDate"]   = (activity.created_at + (year-1).year + 1).end_of_month.strftime(date_format) if year > 1

          if items.has_key?(hash)
            items[hash]["Quantity"] += 1
          else
            items[hash] = {"RN"=>counter.next, "RR" => counter.now - i, "Quantity"=> 1}
          end
        end
      end

      #adding prepaiments
      if items.any?
        total = 0
        items.each{ |key, val| total += val["Quantity"] * key["UnitPriceWoVAT"] }
        hash = {"ProductID" => Setting.directo_receipt_product_name, "Unit" => "tk", "ProductName" => "Domeenide ettemaks", "UnitPriceWoVAT"=>total}
        items[hash] = {"RN"=>counter.next, "RR" => counter.now, "Quantity"=> -1}
      end

      # generating XML
      if items.any?
        directo_next += 1
        invoice_counter.next

        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.invoices{
            xml.invoice("Number"      =>directo_next,
                        "InvoiceDate" =>invoices_until.strftime(date_format),
                        "PaymentTerm" =>Setting.directo_receipt_payment_term,
                        "CustomerCode"=>registrar.directo_handle,
                        "Language"    =>"",
                        "Currency"    =>registrar_activities.first.currency,
                        "SalesAgent"  =>Setting.directo_sales_agent){
              xml.line("RN" => 1, "RR"=>1, "ProductName"=> "Domeenide registreerimine - #{I18n.l(invoices_until, format: "%B %Y").titleize}")
              items.each do |line, val|
                xml.line(val.merge(line))
              end
            }
          }
        end

        data = builder.to_xml.gsub("\n",'')
        response = RestClient::Request.execute(url: ENV['directo_invoice_url'], method: :post, payload: {put: "1", what: "invoice", xmldata: data}, verify_ssl: false).to_s
        if @debug
          STDOUT << "#{Time.zone.now.utc} - Directo xml had to be sent #{data}\n"
        else
          Setting.directo_monthly_number_last = directo_next
          Nokogiri::XML(response).css("Result").each do |res|
            Directo.create!(request: data, response: res.as_json.to_h, invoice_number: directo_next)
            Rails.logger.info("[DIRECTO] Invoice #{res.attributes["docid"].value} was pushed and return is #{res.as_json.to_h.inspect}")
          end
        end
      else
        Rails.logger.info("[DIRECTO] Registrar #{registrar.id} has nothing to be sent to Directo")
      end

    end
    STDOUT << "#{Time.zone.now.utc} - Directo invoices sending finished. #{invoice_counter.now} are sent\n"
  end


  def self.load_activity_pricelist activity
    @pricelists ||= {}
    return @pricelists[activity.log_pricelist_id] if @pricelists.has_key?(activity.log_pricelist_id)

    pricelist = Pricelist.find_by(id: activity.log_pricelist_id) || PricelistVersion.find_by(item_id: activity.log_pricelist_id).try(:reify)
    unless pricelist
      @pricelists[activity.log_pricelist_id] = nil
      Rails.logger.info("[DIRECTO] AccountActivity #{activity.id} cannot be sent as pricelist wasn't found #{activity.log_pricelist_id}")
      return
    end

    @pricelists[activity.log_pricelist_id] = pricelist.version_at(activity.created_at) || pricelist
  end
end

