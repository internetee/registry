xml.epp_head do
  xml.response do
    @errors.each do |x|
      xml.result('code' => x[:code]) do
        xml.msg(x[:msg], 'lang' => 'en')

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

  end

  xml << render('/epp/shared/trID')
end
