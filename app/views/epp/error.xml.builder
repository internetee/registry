xml.epp_head do
  xml.response do
    @errors.each do |error|
      x = error&.options
      next if x.empty? || x == { value: nil } || x[:code].blank?

      xml.result('code' => x[:code]) do
        xml.msg(x[:msg], 'lang' => 'en')
        model_name = resource ? resource.model_name.singular.sub('epp_','') : controller.controller_name.singularize
        prefix = model_name == 'poll' ? 'changePoll' : model_name + '-ee'

        xml.value("xmlns:#{model_name}" => Xsd::Schema.filename(for_prefix: prefix)) do
          value = x[:value][:val]
          attrs = {}
          attrs["s"] = value if x[:value][:obj] == "status"

          if (val = value).respond_to?(:each)
            val.each do |el|
              if el.kind_of?(Array)
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
