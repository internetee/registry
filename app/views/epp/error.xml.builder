xml.epp_head do
  xml.response do
    @errors.each do |x|
      xml.result('code' => x[:code]) do
        xml.msg(x[:msg], 'lang' => 'en')

        xml.value("xmlns:#{controller.controller_name}" => 'https://epp.tld.ee/schema/all-ee-1.0.xsd') do
          value = x[:value][:val]
          attrs = {}
          attrs["s"] = value if x[:value][:obj] == "status"

          if (val = value).respond_to?(:each)
            val.each do |el|
              xml.tag!("#{controller.controller_name}:#{x[:value][:obj]}", el, attrs)
            end
          else
            xml.tag!("#{controller.controller_name}:#{x[:value][:obj]}", val, attrs)
          end
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
