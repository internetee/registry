xml.epp_head do
  xml.response do
    xml.result('code' => @code) do
      xml.msg(@msg, 'lang' => 'en')
    end
  end

  @extValues.each do |x|
    xml.extValue do
      xml.value do
        # xml.tag!()
        xml.reason x.to_s
      end
    end

  end if @extValues && @extValues.any?

  xml << render('/epp/shared/trID')
end
