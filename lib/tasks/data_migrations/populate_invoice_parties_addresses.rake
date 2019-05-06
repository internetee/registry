namespace :data_migrations do
  task populate_invoice_parties_addresses: :environment do
    processed_invoice_count = 0

    Invoice.transaction do
      Invoice.all.each do |invoice|
        seller_address = Address.new(street: invoice.seller_street,
                                     zip: invoice.seller_zip,
                                     city: invoice.seller_city,
                                     state: invoice.seller_state,
                                     country: Country.new(invoice.seller_country_code))

        buyer_address = Address.new(street: invoice.buyer_street,
                                    zip: invoice.buyer_zip,
                                    city: invoice.buyer_city,
                                    state: invoice.buyer_state,
                                    country: Country.new(invoice.buyer_country_code))

        invoice.update_columns(seller_address: seller_address.to_s,
                               buyer_address: buyer_address.to_s)

        processed_invoice_count += 1
      end
    end

    puts "Invoices processed: #{processed_invoice_count}"
  end
end