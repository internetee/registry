xml.epp_head do
  xml.response do
    xml.result code: '1000' do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag! 'domain:infData', 'xmlns:domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd' do
        xml.tag! 'domain:name', @name
        xml.tag! 'domain:status', 's' => @status
      end
    end

    render 'epp/shared/trID', builder: xml
  end
end