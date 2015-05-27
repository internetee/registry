xml.epp_head do
  xml.response do
    @errors.each do |x|
      xml.result('code' => x[:code]) do
        xml.msg(x[:msg], 'lang' => 'en')

        xml.value('xmlns:obj' => 'urn:ietf:params:xml:ns:obj') do
          xml.tag!("obj:#{x[:value][:obj]}", x[:value][:val])
        end if x[:value]

        x[:ext_values].each do |y|
          xml.extValue do
            xml.value do
              # xml.tag!()
              xml.reason y.to_s
            end
          end
        end if x[:ext_values]

      end
    end

    render('epp/shared/trID', builder: xml)
  end
end
