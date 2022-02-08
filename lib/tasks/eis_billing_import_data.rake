TOKEN = ENV['eis_token']
BASE_URL = ""
if Rails.env.staging?
  BASE_URL = ENV['eis_billing_system_base_url_staging']
else
  BASE_URL = ENV['eis_billing_system_base_url_dev']
end

namespace :eis_billing do
  desc 'One time task to export invoice data to billing system'
  task import_invoices: :environment do
    parsed_data = []
    Invoice.all.each do |invoice|
      parsed_data << {
        invoice_number: invoice.number,
        initiator: 'registry',
        transaction_amount: invoice.total
      }
    end

    base_request(url: import_invoice_data_url, json_obj: parsed_data)
  end

  desc 'One time task to export reference number of registrars to billing system'
  task import_references: :environment do
    parsed_data = []
    Registrar.all.each do |registrar|
      parsed_data << {
        reference_number: registrar.reference_no,
        initiator: 'registry'
      }
    end

    base_request(url: import_reference_data_url, json_obj: parsed_data)
  end
end

def import_reference_data_url
  "#{BASE_URL}/api/v1/import_data/reference_data"
end

def import_invoice_data_url
  "#{BASE_URL}/api/v1/import_data/invoice_data"
end

def base_request(url:, json_obj:)
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  headers = {
    'Authorization' => 'Bearer foobar',
    'Content-Type' => 'application/json',
    'Accept' => TOKEN
  }

  unless Rails.env.development?
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  http.post(url, json_obj.to_json, headers)
end
