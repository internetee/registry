namespace :dev do
  task create_bank_transactions: :environment do
    remitter_iban = ENV['remitter_iban']
    beneficiary_iban = Setting.registry_iban

    keystore_password = ENV['lhv_keystore_password']
    keystore_alias = ENV['lhv_keystore_alias']
    keystore = Keystores::JavaKeystore.new
    keystore.load(ENV['lhv_keystore'], keystore_password)
    cert = keystore.get_certificate(keystore_alias)
    key = keystore.get_key(keystore_alias, keystore_password)

    api_base_uri = URI.parse('https://testconnect.lhv.eu/connect-prelive')
    request_headers = { 'content-type' => 'application/xml' }

    request_xml = File.binread(File.join(__dir__, 'bank_transactions.xml'))
    request_xml_doc = Nokogiri::XML(request_xml)
    request_xml_doc.at_css('CstmrCdtTrfInitn > GrpHdr > MsgId').content = SecureRandom.hex
    request_xml_doc.at_css('CstmrCdtTrfInitn > PmtInf > DbtrAcct > Id > IBAN')
                   .content = remitter_iban
    request_xml_doc.at_css('CstmrCdtTrfInitn > PmtInf > CdtTrfTxInf > CdtrAcct > Id > IBAN')
                   .content = beneficiary_iban
    request_body = request_xml_doc.to_xml

    http = Net::HTTP.new(api_base_uri.host, api_base_uri.port)
    http.use_ssl = api_base_uri.is_a?(URI::HTTPS)
    http.cert = cert
    http.key = key
    http.ca_file = ENV['lhv_ca_file']

    http.start do
      response = http.post(api_base_uri.path + '/payment', request_body, request_headers)

      if response.is_a?(Net::HTTPSuccess)
        puts 'Success'
      else
        puts 'Failure'
      end
    end
  end
end