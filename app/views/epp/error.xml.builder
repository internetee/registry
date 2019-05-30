xml.epp_head do
  xml.response do
    @errors.each do |x|
      xml.result('code' => x[:code]) do
        xml.msg(x[:msg], 'lang' => 'en')
        model_name = resource ? resource.model_name.singular.sub('epp_', '') : controller.controller_name.singularize

        if x[:value]
          xml.value("xmlns:#{model_name}" => "https://epp.tld.ee/schema/#{model_name}-eis-1.0.xsd") do
            value = x[:value][:val]
            attrs = {}
            attrs['s'] = value if x[:value][:obj] == 'status'

            if (val = value).respond_to?(:each)
              val.each do |el|
                if el.is_a?(Array)
                  xml.tag!("#{model_name}:#{x[:value][:obj]}") do
                    xml.tag!("#{model_name}:#{el[0]}", el[1], attrs)
                  end
                else
                  xml.tag!("#{model_name}:#{x[:value][:obj]}", el, attrs)
                end
              end
            else
              xml.tag!("#{model_name}:#{x[:value][:obj]}", val, attrs)
            end
          end
        end

        x[:ext_values]&.each do |y|
          xml.extValue do
            xml.value do
              # xml.tag!()
              xml.reason y.to_s
            end
          end
        end
      end
    end

    render('epp/shared/trID', builder: xml)
  end
end
